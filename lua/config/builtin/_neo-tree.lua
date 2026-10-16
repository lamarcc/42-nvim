-- [[ NeoTree configuration ]] --

-- Read dashboard cache
local function readDache()
    local cachedir = vim.fn.stdpath('cache') .. "/" .. 'dashboard'
    if vim.fn.isdirectory(cachedir) then
        vim.fn.mkdir(cachedir, 'p')
    end
    local cache = cachedir .. '/' .. 'cache'
    local fd = vim.loop.fs_open(cache, "r", tonumber('644', 8))
    if fd == nil then
        local fd2 = assert(vim.loop.fs_open(cache, "w", tonumber('644', 8)))
        vim.loop.fs_close(fd2)
        return {}
    end
    local stat = assert(vim.loop.fs_fstat(fd))
    local contents = vim.loop.fs_read(fd, stat.size, 0)
    ---@diagnostic disable-next-line: param-type-mismatch
    local dump = assert(loadstring(contents))
    vim.loop.fs_close(fd)
    return dump()
end

-- Write to dashboard cache
local function writeToDache(content)
    local cachedir = vim.fn.stdpath('cache') .. "/" .. 'dashboard'
    if vim.fn.isdirectory(cachedir) then
        vim.fn.mkdir(cachedir, 'p')
    end
    local cache = cachedir .. '/' .. 'cache'
    local fd = assert(vim.loop.fs_open(cache, "w", tonumber('644', 8)))
    local dump = 'return ' .. vim.inspect(content)
    vim.loop.fs_write(fd, dump, 0)
    vim.loop.fs_close(fd)
end

-- Smart Open Handler, opens binaries externally
local function smarthandler(args)
    local mimetype = vim.fn.system("file --mime-encoding -Lb '" .. args.path .. "'")
    if not (mimetype == "binary\n" and vim.fn.system("file -Lb '" .. args.path .. "'") ~= "empty\n") then
        return { handled = false }
    end

    local openfunc
    local os = vim.fn.system("uname -s")

    if os == "Linux\n" then
        openfunc = "xdg-open"
    elseif os == "Darwin\n" then
        openfunc = "open"
    end
    vim.loop.spawn(openfunc, { args = { args.path } },
    function(code, _)
        if code ~= 0 then
            vim.notify("Error opening " .. args.path)
        else
            vim.notify("Externally opened " .. args.path)
        end
    end)
    return { handled = true }
end

require("neo-tree").setup({
    source_selector = {
        winbar = false,
        statusline = false,
    },
    close_if_last_window = false,
    sources = {
        'filesystem',
        'buffers',
        'git_status',
        'document_symbols'
    },
    event_handlers = {
        {
            event = "file_open_requested",
            handler = smarthandler
        }
    },
    default_component_configs = {
        indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
        },
    },

    window = {
        position = "left",
        width = 32,
        mapping_options = {
            noremap = true,
            nowait = true,
        },
        mappings = {
            ['e'] = function() vim.cmd('Neotree focus filesystem left') end,
            ['b'] = function() vim.cmd('Neotree focus buffers left') end,
            ['g'] = function() vim.cmd('Neotree focus git_status left') end,
            ["<space>"] = {
                "toggle_node",
                nowait = false
            },
            ["<2-LeftMouse>"] = "open_with_window_picker",
            ["<cr>"] = "open_with_window_picker",
            ["<esc>"] = "cancel",
            ["P"] = {
                "toggle_preview",
                config = {
                    use_float = true,
                    use_image_nvim = true
                }
            },
            ["l"] = "focus_preview",
            ["<C-v>"] = "vsplit_with_window_picker",
            ["<C-x>"] = "split_with_window_picker",
            ["t"] = "open_tabnew",
            ["w"] = "open",
            ["z"] = "close_all_nodes",
            ["a"] = {
              "add",
              config = {
                show_path = "none"
              }
            },
            ["A"] = "add_directory",
            ["d"] = "delete",
            ["r"] = "rename",
            ["C"] = "copy",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy_to_clipboard",
            ["m"] = "move",
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
            ["<"] = "prev_source",
            [">"] = "next_source",
            ["i"] = "show_file_details",
        }
    },
    nesting_rules = {},
    filesystem = {
        commands = {
            addToDash = function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                local content = readDache()
                local x = 1
                if content == nil then
                    content = {}
                end
                for _,i in pairs(content) do
                    if i == path then
                        table.remove(content, x)
                        writeToDache(content)
                        vim.notify("Removed " .. path .. " from Dashboard shortcuts.")
                        return
                    end
                    x = x + 1
                end
                table.insert(content, path)
                writeToDache(content)
                vim.notify("Added " .. path .. " to Dashboard shortcuts.")
            end
        },
        filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_hidden = true,
            hide_by_name = {},
            hide_by_pattern = {},
            always_show = {
                ".gitignore",
            },
            always_show_by_pattern = {},
            never_show = {
                ".DS_Store",
                "thumbs.db"
            },
            never_show_by_pattern = {},
        },
        follow_current_file = {
            enabled = false,
            leave_dirs_open = true,
        },
        group_empty_dirs = false,
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
        window = {
            mappings = {
                ["<C-K>"] = "addToDash",
                ["<bs>"] = "navigate_up",
                ["."] = "set_root",
                ["H"] = "toggle_hidden",
                ["/"] = "fuzzy_finder",
                ["D"] = "fuzzy_finder_directory",
                ["#"] = "fuzzy_sorter",
                ["f"] = "filter_on_submit",
                ["<c-J>"] = "clear_filter",
                ["[g"] = "prev_git_modified",
                ["]g"] = "next_git_modified",
                ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                ["oc"] = { "order_by_created", nowait = false },
                ["od"] = { "order_by_diagnostics", nowait = false },
                ["og"] = { "order_by_git_status", nowait = false },
                ["om"] = { "order_by_modified", nowait = false },
                ["on"] = { "order_by_name", nowait = false },
                ["os"] = { "order_by_size", nowait = false },
                ["ot"] = { "order_by_type", nowait = false },
            },
            fuzzy_finder_mappings = {
                ["<down>"] = "move_cursor_down",
                ["<C-n>"] = "move_cursor_down",
                ["<up>"] = "move_cursor_up",
                ["<C-p>"] = "move_cursor_up",
            },
        },
    },
    buffers = {
        follow_current_file = {
            enabled = true,
            leave_dirs_open = true,
        },
        group_empty_dirs = true,
        show_unloaded = true,
        window = {
            mappings = {
                ["bd"] = "buffer_delete",
                ["<bs>"] = "navigate_up",
                ["."] = "set_root",
                ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                ["oc"] = { "order_by_created", nowait = false },
                ["od"] = { "order_by_diagnostics", nowait = false },
                ["om"] = { "order_by_modified", nowait = false },
                ["on"] = { "order_by_name", nowait = false },
                ["os"] = { "order_by_size", nowait = false },
                ["ot"] = { "order_by_type", nowait = false },
            }
        },
    },
    git_status = {
        window = {
            position = "float",
            mappings = {
                ["A"]  = "git_add_all",
                ["gu"] = "git_unstage_file",
                ["ga"] = "git_add_file",
                ["gr"] = "git_revert_file",
                ["gc"] = "git_commit",
                ["gp"] = "git_push",
                ["gg"] = "git_commit_and_push",
                ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                ["oc"] = { "order_by_created", nowait = false },
                ["od"] = { "order_by_diagnostics", nowait = false },
                ["om"] = { "order_by_modified", nowait = false },
                ["on"] = { "order_by_name", nowait = false },
                ["os"] = { "order_by_size", nowait = false },
                ["ot"] = { "order_by_type", nowait = false },
            }
        }
    },
    document_symbols = {
        follow_cursor = false,
        client_filters = "first",
        renderers = {
            root = {
                {"indent"},
                {"icon", default="C" },
                {"name", zindex = 10},
            },
            symbol = {
                {"indent", with_expanders = true},
                {"kind_icon", default="?" },
                {"container",
                content = {
                  {"name", zindex = 10},
                  {"kind_name", zindex = 20, align = "right"},
                  }
                }
            },
        },
        window = {
            position = "right",
            mappings = {
                ["<cr>"] = "jump_to_symbol",
                ["o"] = "jump_to_symbol",
                ["A"] = "noop",
                ["d"] = "noop",
                ["i"] = "noop",
                ["y"] = "noop",
                ["x"] = "noop",
                ["p"] = "noop",
                ["c"] = "noop",
                ["C"] = "noop",
                ["m"] = "noop",
                ["a"] = "noop",
                ["<"] = "noop",
                [">"] = "noop",
                ["/"] = "filter",
                ["f"] = "filter_on_submit",
            },
        },
        custom_kinds = {},
        kinds = {
            Unknown = { icon = "?", hl = "" },
            Root = { icon = "", hl = "NeoTreeRootName" },
            File = { icon = "󰈙", hl = "Tag" },
            Module = { icon = "", hl = "Exception" },
            Namespace = { icon = "󰌗", hl = "Include" },
            Package = { icon = "󰏖", hl = "Label" },
            Class = { icon = "󰌗", hl = "Include" },
            Method = { icon = "", hl = "Function" },
            Property = { icon = "󰆧", hl = "@property" },
            Field = { icon = "", hl = "@field" },
            Constructor = { icon = "", hl = "@constructor" },
            Enum = { icon = "󰒻", hl = "@number" },
            Interface = { icon = "", hl = "Type" },
            Function = { icon = "󰊕", hl = "Function" },
            Variable = { icon = "", hl = "@variable" },
            Constant = { icon = "", hl = "Constant" },
            String = { icon = "󰀬", hl = "String" },
            Number = { icon = "󰎠", hl = "Number" },
            Boolean = { icon = "", hl = "Boolean" },
            Array = { icon = "󰅪", hl = "Type" },
            Object = { icon = "󰅩", hl = "Type" },
            Key = { icon = "󰌋", hl = "" },
            Null = { icon = "", hl = "Constant" },
            EnumMember = { icon = "", hl = "Number" },
            Struct = { icon = "󰌗", hl = "Type" },
            Event = { icon = "", hl = "Constant" },
            Operator = { icon = "󰆕", hl = "Operator" },
            TypeParameter = { icon = "󰊄", hl = "Type" },
        }
    },
})

-- Keymaps
vim.api.nvim_set_keymap("n", "<C-h>", ":Neotree toggle position=left<cr>", {
    silent = true,
    noremap = true
})

vim.api.nvim_set_keymap("n", "<C-d>", ":Neotree toggle document_symbols selector=false position=right<cr>", {
    silent = true,
    noremap = true
})
