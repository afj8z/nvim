-- Minimal nvim config for prompt editing

vim.cmd("syntax off")
vim.o.termguicolors = false

vim.opt.number = false
vim.opt.relativenumber = false

-- Quit on 'q' in normal mode
vim.keymap.set("n", "q", ":wqa<CR>", { silent = true, nowait = true })

-- Map Tab in insert mode to jump to the next placeholder
local action_with_escape = [[<Esc>/:<CR>llgh<C-o>$<C-o>h]]

local action_normal = [[/:<CR>llgh<C-o>$<C-o>h]]

vim.cmd("inoremap <silent> <nowait> <Tab> " .. action_with_escape)

vim.cmd("nnoremap <silent> <nowait> <Tab> " .. action_normal)

vim.cmd("vnoremap <silent> <nowait> <Tab> " .. action_with_escape)

vim.cmd("snoremap <silent> <nowait> <Tab> " .. action_with_escape)
