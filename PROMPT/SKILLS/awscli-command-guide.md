# Amazon AWS awscli command and scripting guidlines
#
- Every command should have a region and a profile in that order as the last 2 flags of the command: Ex: aws s3 ls --region us-east-1 --profile <profilename>
- If it is unclear what profile the command is executing against, stop and ask
- If you need a resource id, try to capture it in an environment variable instead of filling in a placeholder
- Avoid mixing commands in batches that both read and modify settings. 
- When requesting a read-only operation, batches are acceptable
- Discovery command are encouraged
- Double checking or bounds checking to increase overall confidence is encouraged
- When modifying settings
  - Double check why it is being changed and it is still required
  - Attempt to do one setting at a time
  - Double check why it is being changed and it is still required
  - Make sure values being changed are known and not assumed.  Ex. echo environment variables
  - Check return codes of the operation if applicable
  - Verify the value was actually change if applicable
  - If confidence in the change is not ideal, don't hesitate to ask for additional information
