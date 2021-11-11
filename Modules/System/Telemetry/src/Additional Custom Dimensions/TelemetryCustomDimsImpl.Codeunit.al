// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8707 "Telemetry Custom Dims Impl."
{
    Access = Internal;

    var
        AdditionalCommonCustomDimensions: Dictionary of [Text, Dictionary of [Text, Text]];
        AllowedCommonCustomDimensionPublishers: List of [Text];

    procedure AddCommonCustomDimension(CustomDimensionName: Text; CustomDimensionValue: Text; Publisher: Text)
    var
        CustomDimensionDictionary: Dictionary of [Text, Text];
    begin
        if not AllowedCommonCustomDimensionPublishers.Contains(Publisher) then
            exit;

        if AdditionalCommonCustomDimensions.ContainsKey(Publisher) then begin
            AdditionalCommonCustomDimensions.Get(Publisher, CustomDimensionDictionary);
            if not CustomDimensionDictionary.ContainsKey(CustomDimensionName) then
                CustomDimensionDictionary.Add(CustomDimensionName, CustomDimensionValue);
        end else begin
            CustomDimensionDictionary.Add(CustomDimensionName, CustomDimensionValue);
            AdditionalCommonCustomDimensions.Add(Publisher, CustomDimensionDictionary);
        end;
    end;

    procedure GetAdditionalCommonCustomDimensions(ForPublisher: Text): Dictionary of [Text, Text];
    var
        EmptyDictionary: Dictionary of [Text, Text];
    begin
        if AdditionalCommonCustomDimensions.ContainsKey(ForPublisher) then
            exit(AdditionalCommonCustomDimensions.Get(ForPublisher))
        else
            exit(EmptyDictionary);
    end;

    procedure AddAllowedCommonCustomDimensionPublisher(Publisher: Text)
    begin
        if not AllowedCommonCustomDimensionPublishers.Contains(Publisher) then
            AllowedCommonCustomDimensionPublishers.Add(Publisher);
    end;
}