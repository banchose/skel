return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- Define the parrot_status function
    local function parrot_status()
      local status_info = require("parrot.config").get_status_info()
      local status = ""
      if status_info.is_chat then
        status = status_info.prov.chat.name
      else
        status = status_info.prov.command.name
      end
      return string.format("%s(%s)", status, status_info.model)
    end

    -- Add to lualine sections (keeping existing components)
    table.insert(opts.sections.lualine_a, parrot_status)
    -- opts.sections.lualine_a = { parrot_status }

    return opts
  end,
}
