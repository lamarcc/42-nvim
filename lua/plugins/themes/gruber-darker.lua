return {
  'blazkowolf/gruber-darker.nvim',
  opts = {
    bold = true, -- Le deuxième bloc demande 'true', cela écrase le 'false' initial
    invert = {
      signs = false,
      tabline = false,
      visual = false,
    },
    italic = {
      strings = true,   -- Fusionné ici
      comments = true,  -- Ajouté
      operators = false, -- Ajouté
      folds = true,     -- Ajouté
    },
    undercurl = true,
    underline = true,
  },
}
