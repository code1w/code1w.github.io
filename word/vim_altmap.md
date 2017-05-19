"=========== Meta ============
"StrID : 1846
"Title : Vim 中正确使用 Alt映射
"Slug  : 
"Cats  : 随笔
"Tags  : Vim
"=============================
"EditType   : post
"EditFormat : Markdown
"TextAttach : 
"========== Content ==========

最简单的做法是：首先将终端软件的 “使用 Alt键作为 Meta键” 的功能打开，其次将 Alt的模式改为 **ESC+字母**，意思是如果你在终端下按下 ALT+X，那么终端软件将会发送 `<ESC>x` 两个字节过去，字节码为：0x27, 0x78。如果你使用过 NeoVim 或者 Emacs的话，这一步应该早就做过了。


**XShell4 终端设置：**

![](http://skywind3000.github.io/word/images/vim_altmap_1.png)

**SecureCRT：终端设置**

![](http://skywind3000.github.io/word/images/vim_altmap_2.png)

其他终端软件里：

- Putty/MinTTY 默认ALT+X 就是发送 `<ESC>x`过去
- Mac下面的 iTerm2/Terminal.app 需要跟 XShell / SecureCRT一样设置一下
- Ubuntu 下面的 GnomeTerminal 默认也是发送 `<ESC>x`过去的
- 任意平台下面的 xterm 可以配置 `~/.Xdefaults` 来设置这个行为。 

这样的话，不管是 NeoVim 还是 Emacs都识别了，Vim 的话，你可以简单这样：

```text
noremap <ESC>x :echo "ALT-X pressed"<cr>
```

注意 ESC后面是小写 x，如果你是大写 X就变成 ALT+SHIFT+X了。于是你在 Vim 中，ALT+X就能看到后面输出的那句话了。看到这里你也许要问：这和我快速按下 ESC再马上按下 x键有什么区别？答案是没有区别，在终端里面这两个操作是一模一样的键盘码传送过去。

就像你不设置 `ttimeout` 和 `ttimeoutlen`，然后快速在 VIM 里面按下 `<ESC>OP`，Vim 会以为你按下了 <F1>一样。因为 F1 的终端下字符串序列就是 `<ESC>OP` ，而你在 Insert 模式下面马上 `<ESC>` 退出并按下大写 O ，向上插入一行，Vim 将会等待一秒钟（默认 timeout ），确认后面没有一个 P，才会进一步确认不是F1，而是向上插行。

所以更好的做法是直接按照 `<M-x>` 进行映射，并且告诉 vim，`<M-x>`的键盘序列码是多少，然后再加上 ttimeoutlen超时：

```text
noremap <M-x> :echo "ALT-X pressed"<cr>
exec "set <M-x>=\ex"
set ttimeout ttimeoutlen=100
```

这样做的好处是告诉 Vim, ESC+x是一个完整的按键码，并且需要在 100ms以内进行判断，即，如果收到 ESC，并且100ms以后没有后续的x，则是认为是一个单独的ESC键，退出 INSERT模式，否则认为是按下了 ALT+X，这和 Vim处理方向键，处理 F1, F2等功能键的原则是相同的，具体见 `:h set-termcap`:

```text
							*:set-termcap* *E522*
For {option} the form "t_xx" may be used to set a terminal option.  This will
override the value from the termcap.  You can then use it in a mapping.  If
the "xx" part contains special characters, use the <t_xx> form: >
	:set <t_#4>=^[Ot
This can also be used to translate a special code for a normal key.  For
example, if Alt-b produces <Esc>b, use this: >
	:set <M-b>=^[b
(the ^[ is a real <Esc> here, use CTRL-V <Esc> to enter it)
The advantage over a mapping is that it works in all situations.

You can define any key codes, e.g.: >
	:set t_xy=^[foo;
There is no warning for using a name that isn't recognized.  You can map these
codes as you like: >
	:map <t_xy> something
```

这是最完善的 ALT键解决方案了，网上有个流传很广的方式是 `map <ESC>x <M-x>` 然后你后面再映射 `<M-x>` 时就能被触发到，这是错误的方法，不能使用更短的 `ttimeoutlen`来识别键盘码，而会使用普通组合键的 `timeoutlen`来判断，后者一般设置为默认 1000毫秒，所以这样把 26个字母映射后，你 ESC退出 INSERT模式后，一秒内按了任何一个字母就会被当成 ALT+X来处理了，经常误操作。

如此，我们可以在 .vimrc中 for循环将 `<M-0>` 到 `<M-9>`，`<M-a>` 到 `<M-z>`等全部 set一遍，vim中即可正常使用。

早年的终端，处理ALT组合键时，是将单个字符的最高位设置成 1，这也是 vim的默认处理方式，如今 rxvt终端也支持这种模式（见上图 SecureCRT设置面板）。这种键盘码不是 ESC+x的模式，可以直接识别，不需要计算超时，缺点是支持终端较少，对终端编码格式有依赖。

如今基本上 `<ESC>+`的模式基本成为大部分终端的默认方式，主流操作了，详细可以看：`:h map-alt-keys` 以及  `:h set-termcap` 两个文档有具体说明，关于超时部分可以见（`:h esckeys` ）

当然，如果你真能在100ms内连续按下 ESC和 X的话，那是另外一回事情了，你可以调短 `ttimeoutlen`到50ms解决，但是不建议该值低于 25ms，否则在低速网络情况下，你按功能键会被vim错误识别成几个单独的按键序列。


对于牛逼的打字员，也许 `ttimeoutlen` 设置的再短也没有用，当他瞬间快速 ESC退出插入模式并同时按下u时，他可能发现自己居然还呆插入模式中，因为被识别称 ALT+u了，而我们之前把 <ESC>开头的A-Z全部都设置了一遍，这样放错的概率会大很多。

好了，下面是终极解决方法，重新定义终端软件的按键序列码：

<!--more-->

基本主流的终端软件都支持自定义键盘码，我们在 XShell, SecureCRT, iTerm2 中都可以方便的设置自定义键盘，设定按下组合键以后向终端发送什么，有了这个神器，我们可以把所有 ALT的组合键定义成：`<ESC>]{0}x~`，即 ALT+A 和 ALT+B 将发送：`<ESC>]{0}A~` 和 `<ESC>]{0}B~`。

在 ESC后面紧跟一个右中括号的意思是，再牛逼的打字员，基本退出 INSERT模式后基本没有可能在 ttimeoutlen规定的几十毫秒内马上按下右中括号键，这样不管 ALT+什么按键都是这个模式，<ESC>后面都是跟随右中括号。

这个可以说是完全安全的了，{0}的意思是 ALT键，我把 Command键定义为 {1}，其他组合的修饰键定义为 {2}之类的，这样也好表示CTRL+ALT之类的终端原本不支持的组合，最后有一个 `~` 字符代表键码结束。

这样你基本能完全不受限制于终端类型，定义任意的按键组合，比如终端里面完全不支持的 CTRL-数字，你也可以照样这么定义，当然你想在 Vim里按照 `:help set-termcap` 那样 `:set <D-x>=...` 来定义 Command组合或者定义 CTRL-数字组合的键码是不行的，无法告诉 Vim按照一个单独的功能键使用到 ttimeoutlen进行识别，怎么办？

好办，使用键盘上没有的按键来代替，即 F13-F37，`<F13>` - `<F37>` 一共有 25 个虚拟功能键给你使用，足够你用了，比如你可以 `:set <F13>=^[]{3}9~` 然后再终端软件里设置 CTRL+9 发送这个字符串，然后你在 Vim里面就可以把 CTRL+9当成 F13来映射了，Mac 下面的 Command键组合也可以同样处理，没必要使用 MacVim，即时链接到远方的服务器上，Command 键也能正常工作。

好了，最后帖一段代码吧：

```text
function! Terminal_MetaMode(mode)
	if has('nvim') || has('gui_running')
		return
	endif
	function! s:metacode(mode, key)
		if a:mode == 0
			exec "set <M-".a:key.">=\e".a:key
		else
			exec "set <M-".a:key.">=\e]{0}".a:key."~"
		endif
	endfunc
	for i in range(10)
		call s:metacode(a:mode, nr2char(char2nr('0') + i))
	endfor
	for i in range(26)
		call s:metacode(a:mode, nr2char(char2nr('a') + i))
		call s:metacode(a:mode, nr2char(char2nr('A') + i))
	endfor
	if a:mode != 0
		for c in [',', '.', '/', ';', '[', ']', '{', '}']
			call s:metacode(a:mode, c)
		endfor
		for c in ['?', ':', '-', '_']
			call s:metacode(a:mode, c)
		endfor
	else
		for c in [',', '.', '/', ';', '{', '}']
			call s:metacode(a:mode, c)
		endfor
		for c in ['?', ':', '-', '_']
			call s:metacode(a:mode, c)
		endfor
	endif
	if &ttimeout == 0
		set ttimeout
	endif
	if &ttimeoutlen <= 0
		set ttimeoutlen=100
	endif
endfunc

command! -nargs=0 -bang VimMetaInit call Terminal_MetaMode(<bang>0)
```

使用：`:VimMetaInit` 将会把 vim里面的键位码定义为 ESC+ 序列，而使用 `:VimMetaInit!` 则可以定义为我们之前说道的：`<ESC>]{0}x~` 格式，我个人推荐使用是后一种。如果你熟悉终端软件的 keymap配置文件格式，可以用脚本一次性生成所有 ALT+A -> ALT+Z 对应终端的 Keymap配置，否则，浪费点时间，在 GUI上一个个设置上去，再和你的 dotfiles放在一起。

--------
更新：比较一下 Vim默认的 ALT键识别方式（单字节高位设置1），比如 ALT+a，a的ascii码是 97，加上0x80以后值为 225，即发送一个 `\u00e1` 的 unicode字符过去，默认的vim就能识别成 ALT+a了，和 GVim的默认方式一样。

看到这里你可能会问，为什么不把终端设置成 Vim的默认ALT编码，而是要弄一半天 `<ESC>]{0}x~` 不当终端里面要设置，Vim里面也要重新设置一遍？默认方式 rxvt和 xterm等终端还不需要额外配置呢？这个方案好在哪里呢？

默认 ascii + 0x80的方式貌似省事，其实并不是，比如你想发送 unicode的 `\u00e1` 告诉 vim你按下了 ALT+a，那么你需要按照终端的字符编码格式来发送这个 unicode字符：比如你终端编码为 latin1的话，你只需要发送 0xe1 一个字节过去；而如果终端字符编码为 UTF-8的时候，你却需要发送 0xc3, 0xa1两个字节；GBK编码的话又要发送 0xa8, 0xa2两个完全不同的字节。

这就是一个问题，而我们使用 `<ESC>`的话，不管什么编码 `<ESC>` 都是 0x1b (27) 一个字节。再有一个问题是 iTerm2 之类的终端可以设置按下某键发送以 `<ESC>` 开头的字符串，却不能设置让你发送任意二进制，所以我们这个方式基本上是兼容所有终端的方式。

