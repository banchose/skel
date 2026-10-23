> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Direct API Access

> Access the Tinfoil inference endpoint directly via HTTPS (not recommended for production).

You can access the Tinfoil inference endpoint directly via HTTPS, but this is not recommended in production:

1. **No privacy guarantee**: Direct access skips the automatic attestation verification our SDKs perform, so you have no cryptographic proof your data is processed in a secure enclave and no protection against man-in-the-middle attacks. Attestation evidence is recorded in [certificate transparency logs](/verification/verification-in-tinfoil.md#attestation-evidence-in-certificate-transparency), but this does not protect the connection before data is sent, and Tinfoil does not provide supported tooling to reconstruct audit-time verification from those records.
2. **Lower performance**: Our SDKs automatically choose the best secure router / enclave and load balance across them. Direct access can degrade performance.

We maintain direct HTTPS compatibility for debugging and simple testing (e.g., inference requests via cURL).

```bash cURL theme={"dark"}
curl -X POST https://inference.tinfoil.sh/v1/chat/completions \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "<MODEL_NAME>",
    "messages": [{"role": "user", "content": "Hello world"}]
  }'
```


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.