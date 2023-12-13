// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Posting;
using System.Security.User;

page 31285 "Unapply G/L Entries CZA"
{
    Caption = 'Unapply General Ledger Entries';
    DataCaptionExpression = Caption();
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SourceTable = "Detailed G/L Entry CZA";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(DocuNo; DocNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies the document''s number.';
                }
                field(PostDate; PostingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the entry''s Posting Date.';
                }
            }
            repeater(Lines)
            {
                Editable = false;
                ShowCaption = false;
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of G/L entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the posting of the unapply general ledger entries will be recorded.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s Document No.';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the account that the entry has been posted to.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of G/L entries.';
                }
                field("Applied G/L Entry No."; Rec."Applied G/L Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of applied G/L entry.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user associated with the entry.';

                    trigger OnDrillDown()
                    var
                        UserManagement: Codeunit "User Management";
                    begin
                        UserManagement.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number that is assigned to the entry.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Unapply)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Unapply';
                Image = UnApply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Unselect one or more ledger entries that you want to unapply this record.';

                trigger OnAction()
                var
                    GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
                begin
                    if DetailedGLEntryCZA."Entry No." = 0 then
                        Error(NothingToUnapplyErr);
                    GLEntryPostApplicationCZA.PostUnApplyGLEntry(DetailedGLEntryCZA, DocNo, PostingDate);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        InsertEntries();
    end;

    var
        GLAccount: Record "G/L Account";
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        DocNo: Code[20];
        PostingDate: Date;
        NothingToUnapplyErr: Label 'There is nothing to unapply.';

    procedure SetDtldGLEntry(EntryNo: Integer)
    begin
        DetailedGLEntryCZA.Get(EntryNo);
        PostingDate := DetailedGLEntryCZA."Posting Date";
        DocNo := DetailedGLEntryCZA."Document No.";
    end;

    procedure InsertEntries()
    var
        SelectedDetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
        SelectedDetailedGLEntryCZA.SetCurrentKey("Entry No.");
        SelectedDetailedGLEntryCZA.SetRange("Transaction No.", DetailedGLEntryCZA."Transaction No.");
        SelectedDetailedGLEntryCZA.SetRange("G/L Account No.", DetailedGLEntryCZA."G/L Account No.");
        Rec.DeleteAll();
        if SelectedDetailedGLEntryCZA.FindSet() then
            repeat
                Rec := SelectedDetailedGLEntryCZA;
                Rec.Insert();
            until SelectedDetailedGLEntryCZA.Next() = 0;
        GLAccount.Get(DetailedGLEntryCZA."G/L Account No.");
    end;

    procedure Caption(): Text
    var
        CaptionTok: Label '%1 %2 %3 %4', Locked = true;
    begin
        exit(StrSubstNo(CaptionTok, GLAccount."No.", GLAccount.Name, DetailedGLEntryCZA.FieldCaption("G/L Entry No."), DetailedGLEntryCZA."G/L Entry No."));
    end;
}
