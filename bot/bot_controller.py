from botocore.exceptions import ClientError
import boto3
import logging
import uuid
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import time
import json
import asyncio
from pydantic import BaseModel

# Configure logging
logger = logging.getLogger(__name__)

# Fast api
app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

class Agent:
    AGENT_ID = "6LFCK7ERMT"
    AGENT_ALIAS_ID = "H8ARGIHST2"

    def __init__(self) -> None:
        self.client = boto3.client("bedrock-agent")
        self.bedrock_agent_runtime_client = boto3.client("bedrock-agent-runtime")

    def list_agents(self):
        """
        List the available Amazon Bedrock Agents.

        :return: The list of available bedrock agents.
        """

        all_agents = []

        paginator = self.client.get_paginator("list_agents")
        for page in paginator.paginate(PaginationConfig={"PageSize": 10}):
            all_agents.extend(page["agentSummaries"])

        return all_agents

    def get_agent(self, agent_id, log_error=True):
        """
        Gets information about an agent.

        :param agent_id: The unique identifier of the agent.
        :param log_error: Whether to log any errors that occur when getting the agent.
                          If True, errors will be logged to the logger. If False, errors
                          will still be raised, but not logged.
        :return: The information about the requested agent.
        """

        try:
            response = self.client.get_agent(agentId=agent_id)
            agent = response["agent"]
        except ClientError as e:
            if log_error:
                logger.error(f"Couldn't get agent {agent_id}. {e}")
            raise
        else:
            return agent

    async def invoke_agent(self, prompt: str, session_id: str):
        """Invoke agent and yield streaming responses"""
        logger.info(f"Starting invoke_agent with session_id: {session_id}")
        # Create a streaming request
        response = self.bedrock_agent_runtime_client.invoke_agent(
            agentId=self.AGENT_ID,
            agentAliasId=self.AGENT_ALIAS_ID,
            sessionId=session_id,
            inputText=prompt,
        )
        
        return response

    async def stream_chat(self, session_id: str, prompt: str):
        """Stream chat responses"""
        logger.info(f"Starting stream_chat with prompt: {prompt[:50]}...")
        chunk_count = 0
        response = await self.invoke_agent(prompt, session_id)
        for event in response.get("completion"):
            chunk = event["chunk"]
            if chunk:
                chunk_count += 1
                decoded_chunk = chunk['bytes'].decode('utf-8')
                logger.debug(f"Sending chunk #{chunk_count}: {decoded_chunk[:100]}...")
                yield f"{decoded_chunk}\n\n"
        logger.info(f"Finished stream_chat. Total chunks sent: {chunk_count}")


agent = Agent()

class AgentRequest(BaseModel):
    agentId: str
    agentAliasId: str

@app.post('/set_agent')
async def set_agent(request: AgentRequest):
    print(f"Setting agent to {request.agentId} and {request.agentAliasId}")
    agent.AGENT_ID = request.agentId
    agent.AGENT_ALIAS_ID = request.agentAliasId
    return {"message": "Agent set successfully"}

@app.post("/chat")
async def chat(prompt: str, session_id: str = uuid.uuid4().hex):
    return StreamingResponse(
        agent.stream_chat(session_id, prompt),
        media_type='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'Content-Type': 'text/event-stream',
            'Access-Control-Allow-Origin': '*',
        }
    )


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)