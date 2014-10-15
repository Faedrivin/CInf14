%%%%%%%%%%%%%%%%%%%%%%%
%
% CInf Template class 
%
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
% Document class
%%%%%%%%%%%%%%%%%%%%%%%

\LoadClass[11pt,a4paper,oneside]{article}


%%%%%%%%%%%%%%%%%%%%%%%
% Packages
%%%%%%%%%%%%%%%%%%%%%%%

% layout etc.
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage[top=2.5cm, bottom=2.5cm, left=2cm, right=2cm]{geometry}
\RequirePackage{lmodern, listings}

% math
\RequirePackage{amsmath, amssymb, array, IEEEtrantools}

% tables
\RequirePackage{tabularx, multicol, colortbl}

% graphics, diagrams
\RequirePackage{graphicx, tikz}

% other packages
\RequirePackage[
  %pdfdisplaydoctitle = true, % TODO: enable by default, disable in draft mode
  hyperfootnotes     = true,
  colorlinks,
  bookmarksnumbered  = true,
  linkcolor          = lightgray,
  plainpages         = false,
  citecolor          = lightgray
  ]{hyperref}

% not used yet
% subcaption, microtype, textcomp, booktabs, 
 
%%%%%%%%%%%%%%%%%%%%%%%
% Configuration
%%%%%%%%%%%%%%%%%%%%%%%

\author{Rasmus Diederichsen, Sebastian H\"offner}

\lstset{
  xleftmargin  = .2\textwidth, 
  xrightmargin = .2\textwidth,
  basicstyle   = \footnotesize\ttfamily,
  language     = Python,
  breaklines   = true,
  commentstyle = \color{blue},
  keywordstyle = \color{purple}\textbf,
  numberstyle  = \tiny\color{gray},
  numbers      = left,
  stringstyle  = \color{olive},
}

% generate document meta data
\AtBeginDocument{
  \hypersetup{
    pdftitle    = {Informatik C -- \"Ubung \@sheet\ -- \@title},
    pdfauthor   = {\@author},
    pdfsubject  = {\@title},
    pdfcreator  = {LaTeX},
  }
}

% choose tikz libraries
%\usetikzlibrary{automata, arrows}

%%%%%%%%%%%%%%%%%%%%%%%
% Definitions
%%%%%%%%%%%%%%%%%%%%%%%

% sheet number
\def\sheet#1{\def\@sheet{#1}}

% (sub)exercise counter
\newcounter{excount}
\newcounter{subexcount}[excount]

% typewriter left/center/right
\newcolumntype{L}{>{\ttfamily}l}
\newcolumntype{C}{>{\ttfamily}c}
\newcolumntype{R}{>{\ttfamily}r}

% helper for headers/individual rows
\newcolumntype{H}{>{\global\let\currentrowstyle\relax}}
\newcolumntype{h}{>{\currentrowstyle}}
\newcommand{\rowstyle}[1]{\gdef\currentrowstyle{#1}% \rowstyle{style}
  #1\ignorespaces
}

% table emphasis
\newcommand{\temph}{\cellcolor{blue!10}}


%%%%%%%%%%%%%%%%%%%%%%%
% Other Macros
%%%%%%%%%%%%%%%%%%%%%%%

% Generates and prints the title
\newcommand{\cinftitle}{ % \cinftitle
  \begin{center}
    \textbf{\Large Informatik C} \\
    Grundlagen der Technischen Informatik \\
    \@author \\
    \textbf{Tutor:} Markus Rothl\"ubbers\\[\baselineskip]
    
    \textbf{ \LARGE{\"Ubung \@sheet} \large{-- \@title} }
  \end{center}
}

% Prints an exercise headline
\newcommand{\ex}[3][]{ % \ex[Number]{Title}{Points}
  \ifx&#1&
    \stepcounter{excount}
  \else
    \setcounter{excount}{#1}
  \fi
  \ifnum \value{excount}>1
    \par\bigskip
  \fi
  \begin{tabularx}{.9\textwidth}{l>{\centering}Xr}
    \textbf{Aufgabe \@sheet.\arabic{excount}} & \textbf{#2} & \textbf{(#3 P)}
  \end{tabularx}
  \par
}

% Prints a subexercise number
\newcommand{\subex}[1][]{ % \subex[Number]
  \ifx&#1&
    \stepcounter{subexcount}
  \else
    \setcounter{subexcount}{#1}
  \fi
  \par\smallskip
  {\setlength{\parindent}{1.5cm}\textbf{\alph{subexcount})}\ }
}
