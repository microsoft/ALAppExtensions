// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Telemetry;
using System.Utilities;

codeunit 6115 "E-Document Error Helper"
{
    /// <summary>
    /// Use it to get the number of errors for E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <returns> Count of the errors in an an E-Document.</returns>
    procedure ErrorMessageCount(var EDocument: Record "E-Document"): Integer
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetContext(EDocument);
        exit(ErrorMessage.ErrorMessageCount(ErrorMessage."Message Type"::Error));
    end;

    /// <summary>
    /// Use it to get the number of warnings for E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <returns> Count of the warnings in an an E-Document.</returns>
    procedure WarningMessageCount(var EDocument: Record "E-Document"): Integer
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetContext(EDocument);
        exit(ErrorMessage.ErrorMessageCount(ErrorMessage."Message Type"::"Warning"));
    end;

    /// <summary>
    /// Use it to check if there are errors for E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <returns> True if the E-Document has an error.</returns>
    procedure HasErrors(var EDocument: Record "E-Document"): Boolean
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetContext(EDocument.RecordId);
        exit(ErrorMessage.HasErrors(false));
    end;

    /// <summary>
    /// Use it to clear errors for E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    procedure ClearErrorMessages(EDocument: Record "E-Document")
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetRange("Context Record ID", EDocument.RecordId());
        ErrorMessage.DeleteAll();
    end;

    /// <summary>
    /// Use it to log warning message for E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="RelatedRec">Related record that caused the warning.</param>
    /// <param name="FieldNo">Related field that caused the warning.</param>
    /// <param name="Message">Warning message text.</param>
    procedure LogWarningMessage(EDocument: Record "E-Document"; RelatedRec: Variant; FieldNo: Integer; Message: Text)
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetContext(EDocument);
        ErrorMessage.LogMessage(RelatedRec, FieldNo, ErrorMessage."Message Type"::Warning, Message);
    end;

    /// <summary>
    /// Use it to log error message for E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="RelatedRec">Related record that caused the error.</param>
    /// <param name="FieldNo">Related field that caused the error.</param>
    /// <param name="Message">Error message text.</param>    
    procedure LogErrorMessage(EDocument: Record "E-Document"; RelatedRec: Variant; FieldNo: Integer; Message: Text)
    var
        ErrorMessage: Record "Error Message";
    begin
        LogErrorToTelemetry(EDocument, Message);
        ErrorMessage.SetContext(EDocument);
        ErrorMessage.LogMessage(RelatedRec, FieldNo, ErrorMessage."Message Type"::Error, Message);
    end;

    /// <summary>
    /// Use it to log simple error message for E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="Message">Error message text.</param>    
    procedure LogSimpleErrorMessage(var EDocument: Record "E-Document"; Message: Text)
    var
        ErrorMessage: Record "Error Message";
    begin
        LogErrorToTelemetry(EDocument, Message);
        ErrorMessage.SetContext(EDocument);
        ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Error, Message);
    end;

    internal procedure GetTelemetryImplErrLbl(): Text
    begin
        exit(EDocTelemetryImplErr);
    end;

    internal procedure GetTelemetryFeatureName(): Text
    begin
        exit(EDocTelemetryCategoryLbl);
    end;

    local procedure LogErrorToTelemetry(var EDocument: Record "E-Document"; Message: Text)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
        ErrorText: text;
    begin
        ErrorText := GetLastErrorText();
        if ErrorText = '' then
            ErrorText := Message;
        TelemetryDimensions.Add('E-Document', EDocument.ToString());
        TelemetryDimensions.Add('Message', Message);
        FeatureTelemetry.LogError('0000LBJ', GetTelemetryFeatureName(), GetTelemetryImplErrLbl(), ErrorText, GetLastErrorCallStack(), TelemetryDimensions);
    end;

    var
        EDocTelemetryCategoryLbl: Label 'E-Document', Locked = true;
        EDocTelemetryImplErr: Label 'E-Document Implementation Error', Locked = true;
}
