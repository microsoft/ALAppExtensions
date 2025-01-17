// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Security.User;
using System.Utilities;

report 11729 "Cash Desk Hand Over CZP"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/CashDeskHandOver.rdl';
    PreviewMode = PrintLayout;
    Caption = 'Cash Desk Hand Over';
    UsageCategory = None;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(CashDesk_No; CashDeskCZP."No.")
            {
            }
            column(CashDesk_Name; CashDeskCZP.Name)
            {
            }
            column(CashDesk_Responsibility_ID_Release; CashDeskCZP."Responsibility ID (Release)")
            {
            }
            column(CashDesk_Responsibility_ID_Post; CashDeskCZP."Responsibility ID (Post)")
            {
            }
            column(System_CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(System_Today; Today())
            {
            }
            column(System_Time; Time())
            {
            }
            column(Variable_Balance; Balance)
            {
            }
            column(Variable_CurrCode; CurrCode)
            {
            }
            column(Variable_NewRespID; NewRespID)
            {
            }
            column(Variable_RespType; RespType)
            {
            }

            trigger OnPostDataItem()
            begin
                if CurrReport.Preview then
                    if not ConfirmManagement.GetResponseOrDefault(ChangeRespQst, false) then
                        Error('');

                case RespType of
                    RespType::Release:
                        begin
                            if CashDeskCZP."Responsibility ID (Release)" = NewRespID then
                                Error('');
                            CashDeskCZP.Validate("Responsibility ID (Release)", NewRespID);
                            CashDeskCZP.Modify(true);
                        end;
                    RespType::Post:
                        begin
                            if CashDeskCZP."Responsibility ID (Post)" = NewRespID then
                                Error('');
                            CashDeskCZP.Validate("Responsibility ID (Post)", NewRespID);
                            CashDeskCZP.Modify(true);
                        end;
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group("Cash Desk")
                {
                    Caption = 'Cash Desk';
                    Editable = false;
                    field(CashDeskNoCZP; CashDeskCZP."No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No.';
                        ToolTip = 'Specifies the number of cash desk card.';
                    }
                    field(CashDeskNameCZP; CashDeskCZP.Name)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of cash desk card.';
                    }
                    field(BalanceCZP; Balance)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Balance';
                        ToolTip = 'Specifies the cash desk card''s current balance denominated in the applicable foreign currency.';
                    }
                    field(CurrCodeCZP; CurrCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Currency Code';
                        ToolTip = 'Specifies the code of the currency of the amount on cash document line.';
                    }
                }
                group("Old Responsibility")
                {
                    Caption = 'Old Responsibility';
                    Editable = false;
                    field(OldRespReleaseID; CashDeskCZP."Responsibility ID (Release)")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Responsibility ID (Release)';
                        ToolTip = 'Specifies the responsibility ID for release';
                    }
                    field(OldRespPostID; CashDeskCZP."Responsibility ID (Post)")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Responsibility ID (Post)';
                        ToolTip = 'Specifies the responsibility ID for post';
                    }
                }
                group("New Responsibility")
                {
                    Caption = 'New Responsibility';
                    field(RespTypeCZP; RespType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Responsibility';
                        OptionCaption = 'Release,Post';
                        ToolTip = 'Specifies the new responsibility for cash desk (release or post).';
                    }
                    field(NewRespIDCZP; NewRespID)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Responsibility ID';
                        ToolTip = 'Specifies the new responsibility ID for cash desk (user ID of employee).';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            CashDeskUserCZP: Record "Cash Desk User CZP";
                        begin
                            CashDeskUserCZP.FilterGroup(2);
                            CashDeskUserCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                            case RespType of
                                RespType::Release:
                                    CashDeskUserCZP.SetRange(Issue, true);
                                RespType::Post:
                                    CashDeskUserCZP.SetRange(Post, true);
                            end;
                            CashDeskUserCZP.FilterGroup(0);
                            if Page.RunModal(0, CashDeskUserCZP) = Action::LookupOK then
                                NewRespID := CashDeskUserCZP."User ID";
                        end;

                        trigger OnValidate()
                        var
                            CashDeskUserCZP: Record "Cash Desk User CZP";
                            NotCashDeskUserErr: Label 'User %1 is not valid %2.', Comment = '%1 = User ID, %2 = Cash Desk User TablaCaption';
                        begin
                            if NewRespID = '' then
                                exit;
                            CashDeskUserCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                            CashDeskUserCZP.SetRange("User ID", NewRespID);
                            case RespType of
                                RespType::Release:
                                    CashDeskUserCZP.SetRange(Issue, true);
                                RespType::Post:
                                    CashDeskUserCZP.SetRange(Post, true);
                            end;
                            if CashDeskUserCZP.IsEmpty() then
                                Error(NotCashDeskUserErr, NewRespID, CashDeskUserCZP.TableCaption());
                            UserSelection.ValidateUserName(NewRespID);
                        end;
                    }
                }
            }
        }
    }

    labels
    {
        ReportNameLbl = 'Cash Desk Hand Over';
        PageLbl = 'Page';
        CashDeskNoLbl = 'Cash Desk No.';
        NameLbl = 'Name';
        OldResponsibilityReleaseLbl = 'Old Responsibility ID (Release)';
        OldResponsibilityPostLbl = 'Old Responsibility ID (Post)';
        NewResponsibilityReleaseLbl = 'New Responsibility ID (Release)';
        NewResponsibilityPostLbl = 'New Responsibility ID (Post)';
        BalanceLbl = 'Balance';
        HandOverDateLbl = 'Hand Over Date';
        HandOverTimeLbl = 'Hand Over Time';
        GaveLbl = 'Gave';
        TakeLbl = 'Take';
    }

    var
        CashDeskCZP: Record "Cash Desk CZP";
        UserSelection: Codeunit "User Selection";
        ConfirmManagement: Codeunit "Confirm Management";
        RespType: Option Release,Post;
        NewRespID: Code[50];
        CurrCode: Code[10];
        Balance: Decimal;
        ChangeRespQst: Label 'Responsibility will be change.\\Do you want to continue?';

    procedure SetupCashDesk(CashDeskNo: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        CashDeskCZP.Get(CashDeskNo);
        if CashDeskCZP."Currency Code" = '' then begin
            GeneralLedgerSetup.Get();
            CurrCode := GeneralLedgerSetup."LCY Code";
        end else
            CurrCode := CashDeskCZP."Currency Code";
        Balance := CashDeskCZP.CalcBalance();
    end;
}
