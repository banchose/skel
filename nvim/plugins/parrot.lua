-- export PRPLEXITY_API_KEY in ~/.bashrc
return {
  "frankroeder/parrot.nvim",
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim",
  },
  lazy = false,
  cond = os.getenv("PERPLEXITY_API_KEY") ~= nil,
  config = function()
    require("parrot").setup({
      providers = {
        pplx = {
          api_key = os.getenv("PERPLEXITY_API_KEY"),
        },
      },
      hooks = {

        ChatAsk2 = function(parrot, params)
          local template = [[
          In light of your existing knowledge base, please generate a response that
          is succinct and directly addresses the question posed. Prioritize accuracy
          and relevance in your answer, drawing upon the most recent information
          available to you. Aim to deliver your response in a concise manner,
          focusing on the essence of the inquiry.
          Question: {{command}}
          ]]
          local model_obj = parrot.get_model("command")
          parrot.logger.info("Asking model: " .. model_obj.name)
          parrot.Prompt(params, parrot.ui.Target.popup, model_obj, "🤖 Ask ~ ", template)
        end,

        ChatAsk3 = function(parrot, params)
          local template = [[
          Please be more percise than imagninative while being consise 
          Question: {{command}}
          ]]
          local model_obj = parrot.get_model("command")
          parrot.logger.info("Asking model: " .. model_obj.name)
          parrot.Prompt(params, parrot.ui.Target.split, model_obj, "🤖 Ask ~ ", template)
        end,

        ChatAsk4 = function(parrot, params)
          local template = [[
            You are a Bash scripting expert. Please generate scripts that follow these practices:
            Quote Everything: Always double-quote variables (`"$var"`) and subshells.  
            Functions, Not Globals: Put all logic in functions. Provide a `main()` that is called at the end. Avoid global variables; use `readonly` for constants.  
            Local Variables**: Use `local` (or `declare`) for function-scoped variables.  
            Fail Fast**: Always use `set -eo pipefail`. If a command’s failure is acceptable, use `|| true`.  
            Prefer Modern Bash**:
              Define functions like `myfunc() { ... }`, never `function myfunc { ... }`.  
              Use `\[\[ \]\]` instead of `[` or `test` without the escapes.  
            Variable Naming: Use lowercase for local variables; uppercase only for exported environment variables.  
              Use `$( )` instead of backticks.  
            - **Paths**: Favor absolute paths. If relative, prefix with `./`.  
            - **Arguments**: If the function is more than two lines, declare named arguments at the top (`declare arg1="$1" arg2="$2"`).  
            - **Temp Files**: Use `mktemp` and clean up with a `trap`.  
            - **Redirection**: Send warnings/errors to `stderr`; only “machine-readable” or final output to `stdout`.  - **Styling**:  
              - Keep `then`, `do`, etc. on the same line.  
              - Use `printf` over `echo` for clarity.  
              - Provide short, descriptive function names, and optionally a `declare desc="..."`.  
            - **Portability & Readability**: Assume recent Bash but design for clarity. Use environment variables for optional behavior rather than complicated flags.
            ]]
          local model_obj = parrot.get_model("command")
          parrot.logger.info("Asking model: " .. model_obj.name)
          parrot.Prompt(params, parrot.ui.Target.split, model_obj, "🤖 Ask ~ ", template)
        end,

        -- You can add more configuration options here
      },
    })
  end,
  -- Optional: Add key bindings
  keys = {
    { "<leader>pc", "<cmd>PrtChatNew<cr>", desc = "New Parrot Chat" },
    { "<leader>pe", "<cmd>PrtChatToggle<cr>", desc = "Toggle Parrot Chat" },
    { "<leader>pm", "<cmd>PrtModel<cr>", desc = "Toggle Parrot Model" },
    { "<leader>pd", "<cmd>PrtChatDelete<cr>", desc = "Delete Parrot Chat" },
    { "<leader>pp", "<cmd>PrtChatPaste<cr>", desc = "Paste Selected to Parrot Chat" },
  },
}
