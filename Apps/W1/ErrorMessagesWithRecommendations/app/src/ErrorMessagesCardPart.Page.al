// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using System.Utilities;
page 7900 "Error Messages Card Part"
{
    Caption = 'Details';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    SourceTable = "Error Message";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Context_Group)
            {
                Caption = 'Context';

                field(Context; Format(Rec."Context Record ID"))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Record';
                    ToolTip = 'Specifies the context record.';
                    trigger OnDrillDown()
                    begin
                        Rec.HandleDrillDown(Rec.FieldNo("Context Record ID"));
                    end;
                }
                field("Context Field Name"; Rec."Context Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Name';
                    DrillDown = false;
                    ToolTip = 'Specifies the field where the error occurred.';
                }
            }

            group(SubContext_Group)
            {
                Caption = 'Error Location';

                field("Sub-Context Record ID"; SubContextRecCaption)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Record';
                    ToolTip = 'Specifies the location of the error.';

                    trigger OnDrillDown()
                    begin
                        Rec.HandleDrillDown(Rec.FieldNo("Sub-Context Record ID"));
                    end;
                }
                field("Sub-Context Field Name"; SubContextFieldCaption)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Name';
                    DrillDown = false;
                    ToolTip = 'Specifies the field name from where the error occurred.';
                }
            }

            group(Source_Group)
            {
                Caption = 'Source';

                field(Source; SourceRecordCaption)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Record';
                    ToolTip = 'Specifies the record source of the error.';

                    trigger OnDrillDown()
                    begin
                        Rec.HandleDrillDown(Rec.FieldNo("Record ID"));
                    end;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Name';
                    DrillDown = false;
                    ToolTip = 'Specifies the field where the error occurred.';
                }
            }
            group(Support)
            {
                Caption = 'Support';

                field("Support Url"; HelpTxt)
                {
                    Caption = 'Help & Documentation';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL of an external web site that offers additional support.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec."Support Url");
                    end;
                }
                field("Additional Information"; Rec."Additional Information")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies more information than the information shown in the Description field.';
                }
            }
            group(Troubleshooting)
            {
                field(TimeOfError; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'Timestamp';
                    ToolTip = 'The time of error occurrence.';
                }
            }
        }
    }

    var
        HelpTxt: Text;
        HelpLbl: Label 'Read';
        SourceRecordCaption: Text;
        SubContextRecCaption: Text;
        SubContextFieldCaption: Text;

    trigger OnAfterGetCurrRecord()
    var
        RecRef: RecordRef;
    begin
        SourceRecordCaption := '';
        SubContextRecCaption := '';
        SubContextFieldCaption := '';
        HelpTxt := '';

        if RecRef.Get(Rec."Record ID") then
            SourceRecordCaption := RecRef.Caption;
        if RecRef.Get(Rec."Sub-Context Record ID") then begin
            SubContextRecCaption := RecRef.Caption;
            if RecRef.FieldExist(Rec."Sub-Context Field Number") then
                SubContextFieldCaption := RecRef.Field(Rec."Sub-Context Field Number").Caption;
        end;
        if Rec."Support Url" <> '' then
            HelpTxt := HelpLbl;
    end;

    procedure SetRecords(var TempErrorMessage: Record "Error Message" temporary)
    begin
        Rec.Copy(TempErrorMessage, true);
    end;
}

