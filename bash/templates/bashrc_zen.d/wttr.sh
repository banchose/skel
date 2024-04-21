<html>
<head>
<link rel="stylesheet" type="text/css" href="https://adobe-fonts.github.io/source-code-pro/source-code-pro.css">
<link rel="stylesheet" type="text/css" href="/files/style.css" />
</head>
<body>
<pre>
#! /usr/bin/env bash
# If you source this file, it will set WTTR_PARAMS as well as show weather.

# WTTR_PARAMS is space-separated URL parameters, many of which are single characters that can be
# lumped together. For example, &#34;F q m&#34; behaves the same as &#34;Fqm&#34;.
if [[ -z &#34;$WTTR_PARAMS&#34; ]]; then
  # Form localized URL parameters for curl
  if [[ -t 1 ]] &amp;&amp; [[ &#34;$(tput cols)&#34; -lt 125 ]]; then
      WTTR_PARAMS+=&#39;n&#39;
  fi 2&gt; /dev/null
  for _token in $( locale LC_MEASUREMENT ); do
    case $_token in
      1) WTTR_PARAMS+=&#39;m&#39; ;;
      2) WTTR_PARAMS+=&#39;u&#39; ;;
    esac
  done 2&gt; /dev/null
  unset _token
  export WTTR_PARAMS
fi

wttr() {
  local location=&#34;${1// /+}&#34;
  command shift
  local args=&#34;&#34;
  for p in $WTTR_PARAMS &#34;$@&#34;; do
    args+=&#34; --data-urlencode $p &#34;
  done
  curl -fGsS -H &#34;Accept-Language: ${LANG%_*}&#34; $args --compressed &#34;wttr.in/${location}&#34;
}

wttr &#34;$@&#34;

</pre>
</body>
</html>