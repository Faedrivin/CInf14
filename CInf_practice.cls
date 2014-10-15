% CInf Template class
\ProvidesClass{CInf_practice}

\LoadClass[11pt,a4paper,oneside]{article}

\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}

\RequirePackage[top=2.5cm, bottom=2.5cm, left=2cm, right=2cm]{geometry}

\RequirePackage{tabularx}

\RequirePackage{listings}
\lstset{
  xleftmargin=.2\textwidth, xrightmargin=.2\textwidth
}

\def\sheet#1{\def\@sheet{#1}}

\newcommand{\cinftitle}{ % \cinftitle
  \begin{center}
    \textbf{\Large Informatik C}\\
    Grundlagen der Technischen Informatik\\
    Rasmus Diederichsen, Sebastian H\"offner\\
    \textbf{Tutor:} Markus Rothl\"ubbers
    
    \textbf{ \LARGE{\"Ubung \@sheet} \large{-- \@title} }
  \end{center}
}

% exercise counter
\newcounter{excount}

% subexercise counter
\newcounter{subexcount}[excount]

\newcommand{\ex}[3][]{
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

\newcommand{\subex}[1][]{
  \ifx&#1&
    \stepcounter{subexcount}
  \else
    \setcounter{subexcount}{#1}
  \fi
  \par\smallskip
  {\setlength{\parindent}{1.5cm}\textbf{\alph{subexcount})}\ }
}
