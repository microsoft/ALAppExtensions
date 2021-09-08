// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes events that can be used to resolve custom CaptionClass properties.
/// </summary>
codeunit 42 "Caption Class"
{
    Access = Public;
    SingleInstance = true;

    /// <summary>
    /// Integration event for resolving CaptionClass expression, split into CaptionArea and CaptionExpr.
    /// Note there should be a single subscriber per caption area.
    /// The event implements the "resolved" pattern - if a subscriber resolves the caption, it should set Resolved to TRUE.
    /// </summary>
    /// <param name="CaptionArea">The caption area used in the CaptionClass expression. Should be unique for every subscriber.</param>
    /// <param name="CaptionExpr">The caption expression used for resolving the CaptionClass expression.</param>
    /// <param name="Language">The current language ID that can be used for resolving the CaptionClass expression.</param>
    /// <param name="Caption">Exit parameter - the resolved caption</param>
    /// <param name="Resolved">Boolean for marking whether the CaptionClass expression was resolved.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
    end;

    /// <summary>
    /// Integration event for after resolving CaptionClass expression.
    /// </summary>
    /// <param name="Language">The current language ID.</param>
    /// <param name="CaptionExpression">The original CaptionClass expression.</param>
    /// <param name="Caption">The resolved caption expression.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCaptionClassResolve(Language: Integer; CaptionExpression: Text; var Caption: Text[1024])
    begin
    end;
}

