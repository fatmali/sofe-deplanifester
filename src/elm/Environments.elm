module Environments where

import Manifest

import Http exposing (Error)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=), at)
import Effects exposing (Effects, Never)
import Html exposing (div, button, text, Html)
import Html.Events exposing (onClick)
import Signal exposing (Address)

import Actions exposing (Action)
import Models.Environment exposing (Environment)
import Model exposing (Model)

view : Address Action -> Model -> Html
view address model =
  div []
    [ div [] (List.map (\env -> div [] [text env.name]) model.environments)
    , button [onClick address Actions.GetEnvironments] [text "Get Enviros"]
    , Manifest.view address model.manifest
    ]

getEnvironments : Effects Action
getEnvironments =
  Http.getString "/environments"
    |> Task.map parseEnvironments
    |> Task.toMaybe
    |> Task.map Actions.GotEnvironments
    |> Effects.task

parseEnvironments : String -> List Environment
parseEnvironments jsonString =
  safeDecodeEnvironment
  (Json.decodeString environmentsDecoder jsonString)

safeDecodeEnvironment : Result String (List Environment) -> List Environment
safeDecodeEnvironment result =
  case result of
    Err msg ->
      []
    Ok environments ->
      environments

environmentsDecoder : Json.Decoder (List Environment)
environmentsDecoder =
  at ["environments"]
    <| Json.list
    <| Json.object2 Environment
      ("name" := Json.string)
      ("isDefault" := Json.bool)