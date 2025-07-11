// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.DateTime;

table 10030 "IRS Forms Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Boolean)
        {
        }
        field(3; "Collect Details For Line"; Boolean)
        {
        }
        field(4; "Protect TIN"; Enum "IRS 1099 Protect TIN Type")
        {
        }
        field(20; "Email Subject"; Text[250])
        {
        }
        field(21; "Email Body"; Text[2048])
        {
        }
        field(100; Implementation; Enum "IRS Forms Implementation")
        {
        }
        field(150; "Background Task"; Boolean)
        {
        }
        field(151; "Task Start Date/Time"; DateTime)
        {
            DataClassification = SystemMetadata;

            trigger OnLookup()
            var
                DateTimeDialog: Page "Date-Time Dialog";
            begin
                DateTimeDialog.SetDateTime(RoundDateTime("Task Start Date/Time", 1000));
                if DateTimeDialog.RunModal() = Action::OK then
                    "Task Start Date/Time" := DateTimeDialog.GetDateTime();
            end;

            trigger OnValidate()
            begin
                if ("Task Start Date/Time" <> 0DT) and ("Task Start Date/Time" < CurrentDateTime) then
                    "Task Start Date/Time" := CurrentDateTime;
            end;
        }
        field(152; "Run Task Now"; Boolean)
        {

            trigger OnValidate()
            begin
                if Rec."Run Task Now" then
                    Rec."Task Start Date/Time" := CurrentDateTime();
            end;
        }
        field(153; "Data Transfer Task ID"; Guid)
        {

        }
        field(154; "Data Transfer Completed"; Boolean)
        {
        }
        field(155; "Data Transfer Error Message"; Text[1024])
        {
        }
        field(500; "Init Reporting Year"; Integer)
        {
            MinValue = 1;
            MaxValue = 99999;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        EmailSubjectTxt: Label '1099 Form Copy for Your Records';
        EmailBodyTxt: Label 'Dear Sir/Madam,<div>&nbsp;</div><div>We hope this email finds you well. As part of our tax reporting process, we are attaching the 1099 copy substitution form for the payments made to you during the past year. Please review the form, and if you have any questions or need further clarification, feel free to reach out.</div><div><br></div><div>Thank you for your prompt attention to this matter. We appreciate your continued partnership.</div><div><br></div><div>Best regards,</div><div><br></div>%1', Comment = '%1 - Company Name', Locked = true;
        NotPossibleToRunDataTransferErr: Label 'It is not possible to run the data transfer because it is currently in progress.';
        DataTransferAlreadyCompletedErr: Label 'The data transfer has already been completed.';

    procedure InitSetup()
    begin
        if not Rec.Get() then begin
            Rec."Email Subject" := EmailSubjectTxt;
            Rec."Email Body" := StrSubstNo(EmailBodyTxt, CompanyName);
            Rec.Insert(true);
        end;
    end;

    procedure CheckIfDataTransferIsPossible()
    begin
        if not IsNullGuid(Rec."Data Transfer Task ID") then
            error(NotPossibleToRunDataTransferErr);
        if Rec."Data Transfer Completed" then
            Error(DataTransferAlreadyCompletedErr);
    end;

    procedure DataTransferInProgress(): Boolean
    begin
        exit((not IsNullGuid(Rec."Data Transfer Task ID")) and (not Rec."Data Transfer Completed"));
    end;

}
