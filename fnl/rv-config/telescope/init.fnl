(import-macros
  {: -m>}
  :init-macros)

(fn config []
  (let [telescope    (require :telescope)
        actions      (require :telescope.actions)
        action-state (require :telescope.actions.state)
        builtin      (require :telescope.builtin)
        themes       (require :telescope.themes)
        opt {:extensions {:file_browser {:theme :ivy
                                         :mappings {:n {} :i {}}}
                          :ui-select [(themes.get_cursor
                                       {:winblend     10
                                        :previewer    false
                                        :shorten_path false
                                        :border       true})]
                          :fzf {:case_mode :smart_case
                                :override_generic_sorter false
                                :override_file_sorter true
                                :fuzzy true}
                          :media_files {:filetypes {}}}
             :defaults {:borderchars ["─"
                                      "│"
                                      "─"
                                      "│"
                                      "╭"
                                      "╮"
                                      "╯"
                                      "╰"]
                        :path_display {}
                        :color_devicons true
                        :wrap_results true
                        :winblend 20
                        :mappings {:i {:<C-s> (. (require :trouble.providers.telescope)
                                                 :open_with_trouble)}}}}]
    ;; Main setup
    (telescope.setup opt)

    ;; Load extensions
    (when (= (vim.fn.executable :gh) 1)
      (telescope.load_extension :gh))
    (when (= (vim.fn.executable :ueberzug) 1)
      (telescope.load_extension :media_files))
    (telescope.load_extension :file_browser)

    ;; Define custom actions
    (local functions {})

    (fn functions.find_files []
      (builtin.find_files
       (if (< vim.o.columns 128)
         (themes.get_dropdown)
         nil)))

    (fn functions.buffer_git_files []
      (builtin.git_files
       (themes.get_dropdown {:border true
                             :winblend 10
                             :cwd (vim.fn.expand "%:p:h")
                             :shorten_path false
                             :previewer false})))

    (fn functions.live_grep []
      (builtin.live_grep {:previewer false
                          :fzf_separator "|>"}))

    (fn functions.grep_prompt []
      (builtin.grep_string {:search (vim.fn.input "Grep String > ")
                            :path_display [:shorten]}))

    (fn functions.grep_last_search [opts]
      (local opts (or opts {}))
      (local register
             (-m> (vim.fn.getreg "/")
                  [:gsub "\\<" ""]
                  [:gsub "\\>" ""]
                  [:gsub "\\C" ""]))
      (set opts.path_display [:shorten])
      (set opts.word_match :-w)
      (set opts.search register)
      (builtin.grep_string opts))

    (fn functions.oldfiles []
      (builtin.oldfiles))

    (fn functions.help_tags []
      (builtin.help_tags))

    (fn functions.installed_plugins []
      (builtin.find_files {:cwd (.. (vim.fn.stdpath :data)
                                    :/lazy/)}))

    (fn functions.buffers []
      (builtin.buffers {:shorten_path false}))

    (fn functions.curbuf []
      (let [opts (themes.get_dropdown {:winblend 10
                                       :previewer false
                                       :shorten_path false
                                       :border true})]
        (builtin.current_buffer_fuzzy_find opts)))

    (fn functions.search_all_files []
      (builtin.find_files
       {:find_command [:rg
                       :--no-ignore
                       :--files]}))

    (local dk (require :def-keymaps))
    (dk [:n]
        {:f {:name :Find
             :f [functions.find_files        "Find File"]
             :F [functions.search_all_files  "All Files"]
             :r [functions.oldfiles          "Recent Files"]
             :h [functions.help_tags         "Help Tags"]
             :g [functions.live_grep         "Live Grep"]
             :G [functions.grep_last_search  "Last Grep"]
             :c [functions.curbuf            "Current Buffer"]
             :s [functions.grep_prompt       "Static grep"]
             :b [functions.buffers           :Buffers]
             :p [functions.installed_plugins :Plugins]}}
        {:prefix :<leader>})))

{: config}
