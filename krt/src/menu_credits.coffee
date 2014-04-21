"use strict"
define ["jquery"], ($) ->
  Credits = {}

  Credits.showCredits = (menu) ->
    $credits = $ """
      <div class='credits'>
        <p class='cc'>
          Sound samples come from 
          <a href='http://www.freesound.org'>freesound.org</a>.
          Most of the sounds are from user 
          <a href='http://www.freesound.org/people/Seidhepriest/'>Seidhepriest</a>
          (<a href='http://creativecommons.org/licenses/by-nc/3.0/'>CC BY-NC</a>).
          The hum sound was made by user 
          <a href='http://www.freesound.org/people/knova/sounds/169669/'>knova</a>
          (<a href='http://creativecommons.org/licenses/by-nc/3.0/'>CC BY-NC</a>).
        </p>

        <p class='tech'>
          There were many exciting tools and APIs used (or, more precisely,
          they were exciting in 2014):
        </p>

        <ul class='tech'>
          <li>
            <a href='https://developer.mozilla.org/en-US/docs/HTML/Canvas'>HTML Canvas</a>
            to draw it to the screen...
          </li>
          <li>
            <a href='https://developer.mozilla.org/en-US/docs/Web/JavaScript/Typed_arrays'>
            Javascript typed arrays</a> to make it run a little less slow (yes, this <b>is</b>
            a new and exciting feature, at least in the world of web)...
          </li>
          <li>
            <a href='https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage'>
            localStorage</a> to save the settings...
          </li>
          <li>
            <a href='https://developer.mozilla.org/en-US/docs/Web/API/Worker'>Web Workers</a>
            to generate the map in dedicated thread...
          </li>
          <li>
            <a href='http://git-scm.com/'>git</a> to manage the sources and
            <a href='https://github.com/'>Github</a> to host the repository for free...
          </li>
          <li>
            <a href='http://jquery.com/'>jQuery</a> to do the dirty work with DOM...
          </li>
          <li>
            <a href='http://coffeescript.org/'>CoffeeScript</a> to get loads of syntax sugar...
          </li>
          <li>
            ...and last but not least <a href='http://www.vim.org/'>Vim</a>,
            the editor it was all written in. <code>:wqa!</code>
          </li>
        </ul>

        <p class='sources'>
          The sources are to be found on Github, 
          <a href='https://github.com/honzasp/honzasp.github.io/tree/master/krt'>
          honzasp/honzasp.github.io/krt</a>
          (as well as the rest of this web). The license is GNU GPL.
        </p>

        <p class='controls'>
          <input type='button' name='return' value='got it'>
          <input type='button' name='button' value='button'>
        </p>
      </div>
      """

    $return = $credits.find("input[name=return]")
    $return.click ->
      $credits.remove()

    $button = $credits.find("input[name=button]")
    $button.one "click", ->
      $button.attr("value", "please, don't press this button")
      $button.one "click", ->
        $button.attr("value", "it's a trap!")
        $return.attr("disabled", true)
        $button.click ->
          $button.attr("value", "it's a trap!")
          if Math.random() < 0.1
            $return.attr("disabled", false)
            setTimeout((->
              $return.attr("disabled", true)
              $button.attr("value", "too late!")
            ), 800)


    $credits.appendTo(menu.$root)

  Credits
