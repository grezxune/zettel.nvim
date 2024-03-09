# Zettel.nvim

This is my take on creating a Zettelkasten note taking experience in Neovim. I use Obsidian but work mostly in Neovim so I wanted an extremely efficient way to add a note to my Zettelkasten in the middle of my workflow. This plugin allows me to do that. You can configure it to your liking by providing a template file as well as placeholders and what you'd like to see happen with those placeholders. There are two default placeholders which which will be outlined below.

tl;dr: This plugin allows you to create a new note in your Zettelkasten with a single command. You can configure the template and placeholders to your liking.

## Installation and Configuration

#### Lazy package manager
```lua
return {
  'grezxune/zettel.nvim',
  config = function()
    local Zettel = require 'zettel'

    local myZettel = Zettel.setup {
      template_file = '/full/path/to/zettelkasten/template.md',
      destination_location = '/full/path/to/zettelkasten', -- I have mine pointed to my vault/zettelkasten folder
      note_file_format = '.md', -- The format of the notes this plugin will create
      placeholders = { -- These are the default values
        {
          pattern = '{{ID}}',
          value = function(instance)
            return instance.filename
          end,
        },
        {
          pattern = '{{DATE}}',
          value = function()
            return tostring(os.date '%x')
          end,
        },
      },
    }

    vim.keymap.set('n', '<leader>cz', function()
      myZettel:new() -- Creates a new zettel located at `destination_location`
    end, { desc = 'Create Zettel' })
  end,
}
```

## Example template file

```markdown
---
id: {{ID}}
createdAt: {{DATE}}
---

# Body
> The piece of knowledge you wish to capture

# References
> Where did this thought come from? If from yourself, leave blank.
```
