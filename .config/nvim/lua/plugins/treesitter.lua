local parsers = {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline',
  'query', 'vim', 'vimdoc', 'yaml', 'json', 'typescript', 'javascript', 'python',
  'toml', 'rust', 'ruby', 'svelte', 'sql', 'regex', 'make', 'dockerfile', 'cmake',
  'css', 'scss', 'cpp', 'java', 'haskell', 'ocaml', 'elixir', 'go', 'php', 'perl',
  'r', 'clojure', 'pascal',
}

-- Neovim 0.12 removed the `all = false` option of add_predicate/add_directive
-- (deprecated in 0.11). The archived nvim-treesitter master branch still
-- registers its custom predicates (`set-lang-from-info-string!`, `downcase!`,
-- `set-lang-from-mimetype!`, ...) with it and expects one TSNode per capture,
-- but now receives a TSNode[] list. Any query using them (markdown code
-- fences, bash/ruby/php heredocs, html <script type=...>) then crashes with
-- "attempt to call method 'range' (a nil value)". Recreate the shim Neovim
-- dropped: hand such handlers the last node of each capture, as 0.11 did.
-- Remove once nvim-treesitter is migrated to its `main` branch.
local function shim_single_node_handlers()
  if vim.fn.has('nvim-0.12') == 0 then
    return
  end
  local tsq = vim.treesitter.query
  for _, fname in ipairs({ 'add_predicate', 'add_directive' }) do
    local orig = tsq[fname]
    tsq[fname] = function(name, handler, opts)
      if type(opts) == 'table' and opts.all == false then
        local single_node_handler = handler
        handler = function(match, ...)
          local last = {}
          for id, nodes in pairs(match) do
            last[id] = type(nodes) == 'table' and nodes[#nodes] or nodes
          end
          return single_node_handler(last, ...)
        end
      end
      return orig(name, handler, opts)
    end
  end
end

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  pin = true,
  lazy = false,
  build = ':TSUpdate',
  init = shim_single_node_handlers,
  config = function()
    vim.treesitter.language.register('bash', 'zsh')
    vim.treesitter.language.register('ruby', 'conf')
    vim.treesitter.language.register('ruby', 'cfg')

    require('nvim-treesitter.configs').setup({
      ensure_installed = parsers,
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
      indent = { enable = true, disable = { 'ruby' } },
    })
  end,
}
