{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
{-# OPTIONS_GHC -fno-warn-name-shadowing #-}
module Boris.Http.Template.Page.Commit where
import qualified Projector.Html.Runtime
import Boris.Http.Template.Data.Build.Data
import Boris.Http.Template.Data.Commit.Data
import Boris.Http.Template.Data.Project.Data
pageCommit :: Commit -> Projector.Html.Runtime.Html
pageCommit = \commit -> Projector.Html.Runtime.foldHtml [Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "h2") (Projector.Html.Runtime.fold []) (Projector.Html.Runtime.foldHtml [Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "a") (Projector.Html.Runtime.fold [[Projector.Html.Runtime.Attribute (Projector.Html.Runtime.AttributeKey "href") (Projector.Html.Runtime.AttributeValue (Projector.Html.Runtime.concat ["/project/",
                                                                                                                                                                                                                                                                                                                                                                                                                                                       commitProject commit]))]]) (Projector.Html.Runtime.textNode (commitProject commit)),
                                                                                                                                                                                                Projector.Html.Runtime.textNodeUnescaped " : ",
                                                                                                                                                                                                Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "a") (Projector.Html.Runtime.fold [[Projector.Html.Runtime.Attribute (Projector.Html.Runtime.AttributeKey "href") (Projector.Html.Runtime.AttributeValue (Projector.Html.Runtime.concat ["/project/",
                                                                                                                                                                                                                                                                                                                                                                                                                                                       commitProject commit,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       "/commit/",
                                                                                                                                                                                                                                                                                                                                                                                                                                                       commitCommit commit]))]]) (Projector.Html.Runtime.textNode (commitCommit commit))]),
                                                         Projector.Html.Runtime.textNodeUnescaped "  ",
                                                         Projector.Html.Runtime.foldHtml (Projector.Html.Runtime.fmap (\build -> Projector.Html.Runtime.foldHtml [Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "div") (Projector.Html.Runtime.fold []) (Projector.Html.Runtime.foldHtml [Projector.Html.Runtime.textNodeUnescaped " ",
                                                                                                                                                                                                                                                                                                          Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "h4") (Projector.Html.Runtime.fold []) (Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "a") (Projector.Html.Runtime.fold [[Projector.Html.Runtime.Attribute (Projector.Html.Runtime.AttributeKey "href") (Projector.Html.Runtime.AttributeValue (Projector.Html.Runtime.concat ["/project/",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       commitProject commit,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       "/build/",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       commitBuildName build]))]]) (Projector.Html.Runtime.textNode (commitBuildName build))),
                                                                                                                                                                                                                                                                                                          Projector.Html.Runtime.textNodeUnescaped " ",
                                                                                                                                                                                                                                                                                                          Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "div") (Projector.Html.Runtime.fold []) (Projector.Html.Runtime.foldHtml [Projector.Html.Runtime.textNodeUnescaped " ",
                                                                                                                                                                                                                                                                                                                                                                                                                                                  Projector.Html.Runtime.foldHtml (Projector.Html.Runtime.fmap (\id -> Projector.Html.Runtime.foldHtml [Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "span") (Projector.Html.Runtime.fold []) (Projector.Html.Runtime.parentNode (Projector.Html.Runtime.Tag "a") (Projector.Html.Runtime.fold [[Projector.Html.Runtime.Attribute (Projector.Html.Runtime.AttributeKey "href") (Projector.Html.Runtime.AttributeValue (Projector.Html.Runtime.concat ["/build/",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       id]))]]) (Projector.Html.Runtime.foldHtml [Projector.Html.Runtime.textNodeUnescaped "#",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Projector.Html.Runtime.textNode id])),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        Projector.Html.Runtime.textNodeUnescaped " "]) (commitBuildIds build)),
                                                                                                                                                                                                                                                                                                                                                                                                                                                  Projector.Html.Runtime.textNodeUnescaped " "]),
                                                                                                                                                                                                                                                                                                          Projector.Html.Runtime.textNodeUnescaped " "]),
                                                                                                                                                                  Projector.Html.Runtime.textNodeUnescaped " "]) (commitBuilds commit))]
