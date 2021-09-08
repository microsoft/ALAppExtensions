// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Various functions related to headlines functionality.
///
/// Payload - the main text of the headline.
/// Qualifier - smaller text, hint to the payload.
/// Expression property - value for the field on the page with type HeadlinePart.
/// </summary>
codeunit 1439 Headlines
{
    var
        HeadlinesImpl: Codeunit "Headlines Impl.";

    /// <summary>
    /// Truncate the text from the end for its length to be no more than MaxLength.
    /// If the text has to be shortened, "..." is be added at the end.
    /// </summary>
    /// <param name="TextToTruncate">Text that be shortened in order to fit on the headline.</param>
    /// <param name="MaxLength">The maximal length of the string. Usually obtained through
    /// <see cref="GetMaxQualifierLength"/> or <see cref="GetMaxPayloadLength"/> function.</param>
    /// <returns>The truncated text</returns>
    procedure Truncate(TextToTruncate: Text; MaxLength: Integer): Text;
    begin
        exit(HeadlinesImpl.Truncate(TextToTruncate, MaxLength));
    end;

    /// <summary>
    /// Emphasize a string of text in the headline. Applies the style to the text.
    /// </summary>
    /// <param name="TextToEmphasize">The text that the style will be applied on.</param>
    /// <returns>Emphasized text (special tags are added to the input).</returns>
    procedure Emphasize(TextToEmphasize: Text): Text;
    begin
        exit(HeadlinesImpl.Emphasize(TextToEmphasize));
    end;

    /// <summary>
    /// Combine the text from Qualifier and Payload in order to get a single string with headline
    /// text. This text is usually assigned to Expression property on the HeadlinePart page.
    /// </summary>
    /// <param name="Qualifier">The text to be displayed on the qualifier (smaller text above the main one)
    /// of the headline (parts of it can be emphasized, see <see cref="Emphasize"/>).</param>
    /// <param name="Payload">The text to be displayed on the payload (the main text of the headline)
    /// of the headline (parts of it can be emphasized, see <see cref="Emphasize"/>).</param>
    /// <param name="ResultText">Output parameter. Contains the combined text, ready to be assigned to
    /// the Expression property, if the function returns 'true', the unchanged value otherwise.</param>
    /// <returns>'false' if payload is empty, or payload is too long, or qualifier is too long,
    /// 'true' otherwise.</returns>
    procedure GetHeadlineText(Qualifier: Text; Payload: Text; var ResultText: Text): Boolean;
    begin
        exit(HeadlinesImpl.GetHeadlineText(Qualifier, Payload, ResultText));
    end;

    /// <summary>
    /// Get a greeting text for the current user relevant to the time of the day.
    /// Timespans and correspondant greetings:
    /// 00:00-10:59     Good morning, John Doe!
    /// 11:00-13:59     Hi, John Doe!
    /// 14:00-18:59     Good afternoon, John Doe!
    /// 19:00-23:59     Good evening, John Doe!
    /// if the user name is blank for the current user, simplified version 
    /// is used (for example, "Good afternoon!").
    /// </summary>
    /// <returns>The greeting text.</returns> 
    procedure GetUserGreetingText(): Text;
    begin
        exit(HeadlinesImpl.GetUserGreetingText());
    end;

    /// <summary>
    /// Determines if a greeting text should be visible.
    /// </summary>
    /// <returns>True if the user logged in less than 10 minutes ago, false otherwise.</returns>
    procedure ShouldUserGreetingBeVisible(): Boolean;
    begin
        exit(HeadlinesImpl.ShouldUserGreetingBeVisible());
    end;

    /// <summary>
    /// The accepted maximum length of a qualifier.
    /// </summary>
    /// <returns>The number of characters, 50.</returns>    
    procedure GetMaxQualifierLength(): Integer;
    begin
        exit(HeadlinesImpl.GetMaxQualifierLength());
    end;

    /// <summary>
    /// The accepted maximum length of a payload.
    /// </summary>
    /// <returns>The number of characters, 75.</returns>    
    procedure GetMaxPayloadLength(): Integer;
    begin
        exit(HeadlinesImpl.GetMaxPayloadLength());
    end;
}