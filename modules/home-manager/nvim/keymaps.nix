{
  programs.nixvim = {
    keymaps = [
      {
        action = "<C-d>zz";
        key = "<C-d>";
        options = {
          desc = "Keep cursor in middle when jumping";
        };
        mode = [
          "n"
        ];
      }
      {
        action = "<C-u>zz";
        key = "<C-u>";
        options = {
          desc = "Keep cursor in middle when jumping";
        };
        mode = [
          "n"
        ];
      }
      {
        action = "mzJ`z";
        key = "J";
        options = {
          desc = "Combine line into one";
        };
        mode = [
          "n"
        ];
      }
      {
        action = "nzzzv";
        key = "n";
        options = {
          desc = "Keep cursor in middle when searching";
        };
        mode = [
          "n"
        ];
      }
      {
        action = "Nzzzv";
        key = "N";
        options = {
          desc = "Keep cursor in middle when searching";
        };
        mode = [
          "n"
        ];
      }
      {
        action = "v:count == 0 ? 'gj' : 'j'";
        key = "j";
        options = {
          silent = true;
          expr = true;
        };
        mode = [
          "n"
        ];
      }
      {
        action = "v:count == 0 ? 'gk' : 'k'";
        key = "k";
        options = {
          silent = true;
          expr = true;
        };
        mode = [
          "n"
        ];
      }
      {
        action = "<C-w>v";
        key = "<leader>|";
        options = {
          desc = "Split window right";
        };
        mode = [
          "n"
        ];
      }
      {
        action = "<C-w>s";
        key = "<leader>-";
        options = {
          desc = "Split window below";
        };
        mode = [
          "n"
        ];
      }
      {
        action = "<cmd>w<cr><esc>";
        key = "<C-s>";
        options = {
          desc = "Save file";
        };
        mode = [
          "n"
          "v"
          "x"
          "i"
        ];
      }
      {
        action = "'_dP";
        key = "<leader>p";
        options = {
          desc = "Paste without updating buffer";
        };
        mode = [
          "v"
        ];
      }
      {
        action = ">gv";
        key = ">";
        options = {
          desc = "Stay in visual mode during outdent";
        };
        mode = [
          "v"
          "x"
        ];
      }
      {
        action = "<gv";
        key = "<";
        options = {
          desc = "Stay in visual mode during indent";
        };
        mode = [
          "v"
          "x"
        ];
      }

      {
        action = "v:count == 0 ? 'gj' : 'j'";
        key = "<Down>";
        options = {
          desc = "Map <Down> to 'gj' if count is 0, else 'j'";
        };
        mode = [
          "n"
          "x"
        ];
      }
      {
        action = "v:count == 0 ? 'gk' : 'k'";
        key = "<Up>";
        options = {
          desc = "Map <Up> to 'gk' if count is 0, else 'k'";
        };
        mode = [
          "n"
          "x"
        ];
      }


      {
        action = "<C-w>h";
        key = "<C-h>";
        options = {
          desc = "Go to left window";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<C-w>j";
        key = "<C-j>";
        options = {
          desc = "Go to lower window";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<C-w>k";
        key = "<C-k>";
        options = {
          desc = "Go to upper window";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<C-w>l";
        key = "<C-l>";
        options = {
          desc = "Go to right window";
          remap = true;
        };
        mode = [ "n" ];
      }

      {
        action = "<cmd>resize +2<cr>";
        key = "<C-Up>";
        options = {
          desc = "Increase window height";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>resize -2<cr>";
        key = "<C-Down>";
        options = {
          desc = "Decrease window height";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>vertical resize -2<cr>";
        key = "<C-Left>";
        options = {
          desc = "Decrease window width";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>vertical resize +2<cr>";
        key = "<C-Right>";
        options = {
          desc = "Increase window width";
        };
        mode = [ "n" ];
      }


      {
        action = "<cmd>m .+1<cr>==";
        key = "<A-j>";
        options = {
          desc = "Move down";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>m .-2<cr>==";
        key = "<A-k>";
        options = {
          desc = "Move up";
        };
        mode = [ "n" ];
      }
      {
        action = "<esc><cmd>m .+1<cr>==gi";
        key = "<A-j>";
        options = {
          desc = "Move down";
        };
        mode = [ "i" ];
      }
      {
        action = "<esc><cmd>m .-2<cr>==gi";
        key = "<A-k>";
        options = {
          desc = "Move up";
        };
        mode = [ "i" ];
      }
      {
        action = ":m '>+1<cr>gv=gv";
        key = "<A-j>";
        options = {
          desc = "Move down";
        };
        mode = [ "v" ];
      }
      {
        action = ":m '<-2<cr>gv=gv";
        key = "<A-k>";
        options = {
          desc = "Move up";
        };
        mode = [ "v" ];
      }

      {
        action = "<cmd>bprevious<cr>";
        key = "<S-h>";
        options = {
          desc = "Prev buffer";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>bnext<cr>";
        key = "<S-l>";
        options = {
          desc = "Next buffer";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>bprevious<cr>";
        key = "[b";
        options = {
          desc = "Prev buffer";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>bnext<cr>";
        key = "]b";
        options = {
          desc = "Next buffer";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>e #<cr>";
        key = "<leader>bb";
        options = {
          desc = "Switch to Other Buffer";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>e #<cr>";
        key = "<leader>`";
        options = {
          desc = "Switch to Other Buffer";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>noh<cr><esc>";
        key = "<esc>";
        options = {
          desc = "Escape and clear hlsearch";
        };
        mode = [ "i" "n" ];
      }
      {
        action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
        key = "<leader>ur";
        options = {
          desc = "Redraw / clear hlsearch / diff update";
        };
        mode = [ "n" ];
      }
      {
        action = "'Nn'[v:searchforward].'zv'";
        key = "n";
        options = {
          desc = "Next search result";
          expr = true;
        };
        mode = [ "n" ];
      }
      {
        action = "'Nn'[v:searchforward]";
        key = "x";
        options = {
          desc = "Next search result";
          expr = true;
        };
        mode = [ "x" ];
      }
      {
        action = "'Nn'[v:searchforward]";
        key = "o";
        options = {
          desc = "Next search result";
          expr = true;
        };
        mode = [ "o" ];
      }
      {
        action = "'nN'[v:searchforward].'zv'";
        key = "N";
        options = {
          desc = "Prev search result";
          expr = true;
        };
        mode = [ "n" ];
      }
      {
        action = "'nN'[v:searchforward]";
        key = "X";
        options = {
          desc = "Prev search result";
          expr = true;
        };
        mode = [ "x" ];
      }
      {
        action = "'nN'[v:searchforward]";
        key = "O";
        options = {
          desc = "Prev search result";
          expr = true;
        };
        mode = [ "o" ];
      }
      {
        action = ",<c-g>u";
        key = ",";
        options = { };
        mode = [ "i" ];
      }
      {
        action = ".<c-g>u";
        key = ".";
        options = { };
        mode = [ "i" ];
      }
      {
        action = ";<c-g>u";
        key = ";";
        options = { };
        mode = [ "i" ];
      }
      {
        action = "<cmd>w<cr><esc>";
        key = "<C-s>";
        options = {
          desc = "Save file";
        };
        mode = [ "i" "x" "n" "s" ];
      }
      {
        action = "<cmd>norm! K<cr>";
        key = "<leader>K";
        options = {
          desc = "Keywordprg";
        };
        mode = [ "n" ];
      }
      {
        action = "<gv";
        key = "<";
        options = { };
        mode = [ "v" ];
      }
      {
        action = ">gv";
        key = ">";
        options = { };
        mode = [ "v" ];
      }

      {
        action = "<cmd>enew<cr>";
        key = "<leader>fn";
        options = {
          desc = "New File";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>lopen<cr>";
        key = "<leader>xl";
        options = {
          desc = "Location List";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>copen<cr>";
        key = "<leader>xq";
        options = {
          desc = "Quickfix List";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>qa<cr>";
        key = "<leader>qq";
        options = {
          desc = "Quit all";
        };
        mode = [ "n" ];
      }
      {
        action = "<c-\\><c-n>";
        key = "<esc><esc>";
        options = {
          desc = "Enter Normal Mode";
        };
        mode = [ "t" ];
      }
      {
        action = "<cmd>wincmd h<cr>";
        key = "<C-h>";
        options = {
          desc = "Go to left window";
        };
        mode = [ "t" ];
      }
      {
        action = "<cmd>wincmd j<cr>";
        key = "<C-j>";
        options = {
          desc = "Go to lower window";
        };
        mode = [ "t" ];
      }
      {
        action = "<cmd>wincmd k<cr>";
        key = "<C-k>";
        options = {
          desc = "Go to upper window";
        };
        mode = [ "t" ];
      }
      {
        action = "<cmd>wincmd l<cr>";
        key = "<C-l>";
        options = {
          desc = "Go to right window";
        };
        mode = [ "t" ];
      }
      {
        action = "<cmd>close<cr>";
        key = "<C-/>";
        options = {
          desc = "Hide Terminal";
        };
        mode = [ "t" ];
      }
      {
        action = "<cmd>close<cr>";
        key = "<c-_>";
        options = {
          desc = "which_key_ignore";
        };
        mode = [ "t" ];
      }
      {
        action = "<C-W>p";
        key = "<leader>ww";
        options = {
          desc = "Other window";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<C-W>c";
        key = "<leader>wd";
        options = {
          desc = "Delete window";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<C-W>s";
        key = "<leader>w-";
        options = {
          desc = "Split window below";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<C-W>v";
        key = "<leader>w|";
        options = {
          desc = "Split window right";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<C-W>s";
        key = "<leader>-";
        options = {
          desc = "Split window below";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<C-W>v";
        key = "<leader>|";
        options = {
          desc = "Split window right";
          remap = true;
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>tablast<cr>";
        key = "<leader><tab>l";
        options = {
          desc = "Last Tab";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>tabfirst<cr>";
        key = "<leader><tab>f";
        options = {
          desc = "First Tab";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>tabnew<cr>";
        key = "<leader><tab><tab>";
        options = {
          desc = "New Tab";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>tabnext<cr>";
        key = "<leader><tab>]";
        options = {
          desc = "Next Tab";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>tabclose<cr>";
        key = "<leader><tab>d";
        options = {
          desc = "Close Tab";
        };
        mode = [ "n" ];
      }
      {
        action = "<cmd>tabprevious<cr>";
        key = "<leader><tab>[";
        options = {
          desc = "Previous Tab";
        };
        mode = [ "n" ];
      }










































































    ];
  };
}
