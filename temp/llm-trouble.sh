llm_trouble_confs() {

  # symlinked to ~/.config/io.datasette.llm/ and litellm
  readonly llmextra=~/gitdir/skel/llm/litellm/extra-openai-models.yaml
  readonly litellmconf=~/gitdir/skel/llm/litellm/litellm.conf

  echo "llm models list"
  echo "Under OpenAI: OpenAI Chat: tinfoil-kimi-k2-5 (aliases: kimi, kim)"

  [[ -f ${llmextra} ]] || {
    echo "no  ${llmextra} found"
    return 1
  }

  echo "${llmextra}"
  echo "------"
  grep -E '(model_name:|model_id:)' ~/gitdir/skel/llm/litellm/extra-openai-models.yaml
  echo "${litellmconf}"
  echo "------"
  grep -E '(model_name:|model:|litellm)' ~/gitdir/skel/llm/litellm/litellm.conf

}
