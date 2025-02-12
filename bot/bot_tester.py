from serpapi import GoogleSearch
import boto3
import json

query = "Who is the president of iceland"
params = {
        "api_key": "9d659b4c705628ceda9721a3cce353e8aef75363d4b77754e7976c57731650e2",
        "engine": "google",
        "q": query,
    }

serach_result = GoogleSearch(
    params
).get_dict()

client = boto3.client("bedrock-runtime")
print(serach_result)
response = client.invoke_model(
    modelId="mistral.mistral-7b-instruct-v0:2",
    body=json.dumps({
        "prompt": f"""Based on the following search results, ONLY answer the question based on the search results: 
        {query}. 
        Include as much detail as possible. If the answer is not in the search results, say "No information found".
        Search results: {serach_result}""",
    }).encode("utf-8")
)

answer = ""
for event in response.get("body"):
    chunk = event
    answer += chunk.decode('utf-8')

print(answer)