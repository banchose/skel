return {
  "frankroeder/parrot.nvim",
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim",
  },
  lazy = false,
  cond = os.getenv("ANTHROPIC_API_KEY") ~= nil,
  config = function()
    require("parrot").setup({
      providers = {
        anthropic = {
          api_key = os.getenv("ANTHROPIC_API_KEY"),
        },
      },
      hooks = {
        -- Custom chat with concise responses prompt
        ConciseChat = function(parrot, params)
          local chat_prompt = [[
          In light of your existing knowledge base, please generate responses that
          are succinct and directly address the questions posed. Prioritize accuracy
          and relevance in your answers, drawing upon the most recent information
          available to you. Aim to deliver your responses in a concise manner,
          focusing on the essence of the inquiry.
          ]]
          parrot.ChatNew(params, chat_prompt, parrot.ui.Target.split)
        end,

        -- Custom chat with precise over imaginative prompt
        PreciseChat = function(parrot, params)
          local chat_prompt = [[
          Please be more precise than imaginative while being concise in all your responses.
          Focus on factual information and clear explanations rather than creative interpretations.
          ]]
          parrot.ChatNew(params, chat_prompt, parrot.ui.Target.split)
        end,

        -- Custom chat with Bash expert prompt (using string concatenation)
        BashExpertChat = function(parrot, params)
          local chat_prompt = "You are a Bash scripting expert. Please generate scripts that follow these practices:\n"
            .. '- Quote Everything: Always double-quote variables ("$var") and subshells.\n'
            .. "- Functions, Not Globals: Put all logic in functions. Provide a main() that is called at the end. Avoid global variables; use readonly for constants.\n"
            .. "- Local Variables: Use local (or declare) for function-scoped variables.\n"
            .. "- Fail Fast: Always use set -eo pipefail. If a command's failure is acceptable, use || true.\n"
            .. "- Prefer Modern Bash:\n"
            .. "  - Define functions like myfunc() { ... }, never function myfunc { ... }.\n"
            .. "  - Use [[ ]] instead of [ or test.\n"
            .. "- Variable Naming: Use lowercase for local variables; uppercase only for exported environment variables.\n"
            .. "  - Use $( ) instead of backticks.\n"
            .. "- Paths: Favor absolute paths. If relative, prefix with ./\n"
            .. '- Arguments: If the function is more than two lines, declare named arguments at the top (declare arg1="$1" arg2="$2").\n'
            .. "- Temp Files: Use mktemp and clean up with a trap.\n"
            .. '- Redirection: Send warnings/errors to stderr; only "machine-readable" or final output to stdout.\n'
            .. "- Styling:\n"
            .. "  - Keep then, do, etc. on the same line.\n"
            .. "  - Use printf over echo for clarity.\n"
            .. '  - Provide short, descriptive function names, and optionally a declare desc="...".\n'
            .. "- Portability & Readability: Assume recent Bash but design for clarity. Use environment variables for optional behavior rather than complicated flags."

          parrot.ChatNew(params, chat_prompt, parrot.ui.Target.split)
        end,
      },
    })
  end,
  -- Keys to trigger the custom chat sessions
  keys = {
    -- Default keys from parrot.nvim
    { "<leader>pc", "<cmd>PrtChatNew<cr>", desc = "New Parrot Chat" },
    { "<leader>pe", "<cmd>PrtChatToggle<cr>", desc = "Toggle Parrot Chat" },
    { "<leader>pm", "<cmd>PrtModel<cr>", desc = "Toggle Parrot Model" },
    { "<leader>pd", "<cmd>PrtChatDelete<cr>", desc = "Delete Parrot Chat" },
    { "<leader>pp", "<cmd>PrtChatPaste<cr>", desc = "Paste Selected to Parrot Chat" },

    -- Custom chat session keybindings
    { "<leader>p2", "<cmd>PrtConciseChat<cr>", desc = "Concise Chat" },
    { "<leader>p3", "<cmd>PrtPreciseChat<cr>", desc = "Precise Chat" },
    { "<leader>p4", "<cmd>PrtBashExpertChat<cr>", desc = "Bash Expert Chat" },
  },
}
