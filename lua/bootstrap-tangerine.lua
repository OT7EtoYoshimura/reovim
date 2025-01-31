--- HELPERS ---

-- "tangerine", "packer", "paq", "lazy"
local pack = "lazy"

local function bootstrap(url, ref)
    local name = url:gsub(".*/", "")
    local path

    if pack == "lazy" then
        path = vim.fn.stdpath("data") .. "/lazy/" .. name
        vim.opt.rtp:prepend(path)
    else
        path = vim.fn.stdpath("data") .. "/site/pack/".. pack .. "/start/" .. name
    end

    if vim.fn.isdirectory(path) == 0 then
        print(name .. ": installing in data dir...")

        vim.fn.system({"git", "clone", url, path})
        if ref then
            vim.fn.system({"git", "-C", path, "checkout", ref})
        end

        vim.cmd("redraw")
        print(name .. ": finished installing")
    end
end

--- BOOTSTRAP TANGERINE ---

bootstrap("https://github.com/udayvir-singh/tangerine.nvim", "v2.7")

--- CONFIGURE TANGERINE ---

local nvim_config = vim.fn.stdpath("config")
local nvim_data   = vim.fn.stdpath("data")

local opt = {
    vimrc   = nvim_config .. "/init.fnl",
    source  = nvim_config .. "/fnl",
    target  = nvim_data .. "/tangerine",
    rtpdirs = {
        "plugin",
        "ftdetect",
        "after",
    },

    custom = {
        -- list of custom [source target] chunks, for example:
        -- {"~/.config/awesome/fnl", "~/.config/awesome/lua"}
    },

    compiler = {
        float   = true,     -- show output in floating window
        clean   = true,     -- delete stale lua files
        force   = false,    -- disable diffing (not recommended)
        verbose = true,     -- enable messages showing compiled files

        globals = vim.tbl_keys(_G), -- list of alowedGlobals
        version = "latest",         -- version of fennel to use, [ latest, 1-3-0, 1-2-1, 1-2-0, 1-1-0, 1-0-0, 0-10-0, 0-9-2 ]

        -- hooks for tangerine to compile on:
        -- "onsave" run every time you save fennel file in {source} dir
        -- "onload" run on VimEnter event
        -- "oninit" run before sourcing init.fnl [recommended than onload]
        hooks = { "oninit", "onsave" },
    },

    eval = {
        float  = true,      -- show results in floating window

        -- luafmt = function() -- function that returns formatter with flags for peeked lua
        --     -- optionally install lua-format by `$ luarocks install --local --server=https://luarocks.org/dev luaformatter`
        --     return {"~/.luarocks/bin/lua-format", ...}
        -- end,

        diagnostic = {
            virtual = true,  -- show errors in virtual text
            timeout = 10,    -- how long should the error persist
        },
    },

    keymaps = {
        -- set them to <Nop> if you want to disable them
        eval_buffer = "gE",
        peek_buffer = "gL",
        goto_output = "gO",
        float = {
            next    = "<C-K>",
            prev    = "<C-J>",
            kill    = "<Esc>",
            close   = "<Enter>",
            resizef = "<C-W>=",
            resizeb = "<C-W>-",
        },
    },

    highlight = {
        float   = "Normal",
        success = "String",
        errors  = "DiagnosticError",
    },
}

require("tangerine").setup(opt)

vim.opt.rtp:prepend(nvim_data .. "/tangerine")

--- BOOTSTRAP LAZY.NVIM ---

bootstrap("https://github.com/folke/lazy.nvim")
