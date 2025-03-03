module View.Posts exposing (..)

import Html exposing (Html, div, text, table, thead, tbody, tr, th, td, a, label, select, option, input)
import Html.Attributes exposing (href, class, id, value, selected, type_, checked)
import Html.Events exposing (onCheck, onInput)
import Model exposing (Msg(..))
import Model.Post exposing (Post)
import Model.PostsConfig exposing (Change(..), PostsConfig, SortBy(..), filterPosts, sortFromString, sortOptions, sortToCompareFn, sortToString, defaultConfig)
import Time
import Util.Time


{-| Show posts as a HTML [table](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/table)

Relevant local functions:

  - Util.Time.formatDate
  - Util.Time.formatTime
  - Util.Time.formatDuration (once implemented)
  - Util.Time.durationBetween (once implemented)

Relevant library functions:

  - [Html.table](https://package.elm-lang.org/packages/elm/html/latest/Html#table)
  - [Html.tr](https://package.elm-lang.org/packages/elm/html/latest/Html#tr)
  - [Html.th](https://package.elm-lang.org/packages/elm/html/latest/Html#th)
  - [Html.td](https://package.elm-lang.org/packages/elm/html/latest/Html#td)

-}
postTable : PostsConfig -> Time.Posix -> List Post -> Html Msg
postTable config currTime posts =
    let
        filteredAndSortedPosts = filterPosts config posts
    in
    table []
        [ thead []
            [ tr [] 
                [ th [] [text "Score"]
                , th [] [text "Title"]
                , th [] [text "Type"]
                , th [] [text "Posted"]
                , th [] [text "Link"]
                ]
            ]
        ,   tbody []
                (List.map (postTableRow currTime) filteredAndSortedPosts)
        ]

postTableRow : Time.Posix -> Post -> Html Msg
postTableRow currTime post =
    let
        duration = Util.Time.durationBetween post.time currTime
        formattedTime = Util.Time.formatTime Time.utc post.time
    in
    tr []
        [ td [class "post-score"] [text (String.fromInt post.score)]
        , td [class "post-title"] [text post.title]
        , td [class "post-type"] [text post.type_]
        , td [class "post-time"] [text (
                    case duration of 
                        Nothing -> formattedTime ++ "[" ++ "" ++ "]"
                        Just value -> 
                            let
                                formatedDuration = Util.Time.formatDuration value 
                            in
                                formattedTime ++ "[" ++ formatedDuration ++ "]"
        )]
        , td [class "post-url"] [
                     post.url
                        |> Maybe.map (\url -> a [ href url ] [ text url ])
                        >> Maybe.withDefault (text "No URL found")
                    ]
        ]
        

{-| Show the configuration options for the posts table

Relevant functions:

  - [Html.select](https://package.elm-lang.org/packages/elm/html/latest/Html#select)
  - [Html.option](https://package.elm-lang.org/packages/elm/html/latest/Html#option)
  - [Html.input](https://package.elm-lang.org/packages/elm/html/latest/Html#input)
  - [Html.Attributes.type\_](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#type_)
  - [Html.Attributes.checked](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#checked)
  - [Html.Attributes.selected](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#selected)
  - [Html.Events.onCheck](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onCheck)
  - [Html.Events.onInput](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onInput)

-}

postsConfigView : PostsConfig -> Html Msg
postsConfigView config =
    div []
        [ div []
            [ label [] [ text "Posts per page:" ]
            , select
                [ id "select-posts-per-page"
                , onInput (\str -> 
                    case String.toInt str of
                        Just num -> ConfigChanged (ChangePostsPerPage num)
                        Nothing -> ConfigChanged (ChangePostsPerPage defaultConfig.postsToShow)
                  ) ]
                [ option [ value "10", selected (config.postsToShow == 10) ] [ text "10" ]
                , option [ value "25", selected (config.postsToShow == 25) ] [ text "25" ]
                , option [ value "50", selected (config.postsToShow == 50) ] [ text "50" ]
                ]
            ]
        , div []
            [ label [] [ text "Sort by:" ]
            , select
                [ id "select-sort-by", onInput (\str -> 
                    case sortFromString str of
                        Just sortBy -> ConfigChanged (ChangeSortBy sortBy)
                        Nothing -> ConfigChanged (ChangeSortBy None)
                  ) ]
                [ option [ value "Score", selected (config.sortBy == Score) ] [ text "Score" ]
                , option [ value "Title", selected (config.sortBy == Title) ] [ text "Title" ]
                , option [ value "Date", selected (config.sortBy == Posted) ] [ text "Posted" ]
                , option [ value "None", selected (config.sortBy == None) ] [ text "None" ]
                ]
            ]
        , div []
            [ input
                [ id "checkbox-show-job-posts"
                , type_ "checkbox"
                , checked config.showJobs
                , onCheck (\_ -> ConfigChanged ToggleShowJobs) ]
                []
            , label [] [ text "Show job posts" ]
            ]
        , div []
            [ input
                [ id "checkbox-show-text-only-posts"
                , type_ "checkbox"
                , checked config.showTextOnly
                , onCheck (\_ -> ConfigChanged ToggleShowTextOnly) ]
                []
            , label [] [ text "Show text for posts without URL" ]
            ]
        ]