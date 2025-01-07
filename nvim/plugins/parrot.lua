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

        Ask2 = function(parrot, params)
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

        -- You can add more configuration options here
      },
    })
  end,
  -- Optional: Add key bindings
  keys = {
    { "<leader>pc", "<cmd>PrtChatNew<cr>", desc = "New Parrot Chat" },
    { "<leader>pe", "<cmd>PrtChatToggle<cr>", desc = "Toggle Parrot Chat" },
    { "<leader>pm", "<cmd>PrtModel<cr>", desc = "Toggle Parrot Model" },
  },
}
