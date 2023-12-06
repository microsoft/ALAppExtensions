// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

report 11725 "Copy Cash Document CZP"
{
    Caption = 'Copy Cash Document';
    ProcessingOnly = true;
    UsageCategory = None;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CashDeskNoCZP; CashDeskNo)
                    {
                        ApplicationArea = Suite;
                        TableRelation = "Cash Desk CZP";
                        Caption = 'Cash Desk No.';
                        ToolTip = 'Specifies the number of the cash desk from which is created cash document that is processed by the report or batch job.';

                        trigger OnValidate()
                        begin
                            ValidateCashDeskNo();
                        end;
                    }
                    field(DocumentTypeCZP; DocType)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Document Type';
                        OptionCaption = 'Cash Document,Posted Cash Document';
                        ToolTip = 'Specifies the type of document that is processed by the report or batch job.';

                        trigger OnValidate()
                        begin
                            DocNo := '';
                            ValidateDocNo();
                        end;
                    }
                    field(DocumentNo; DocNo)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupDocNo();
                        end;

                        trigger OnValidate()
                        begin
                            ValidateDocNo();
                        end;
                    }
                    field(IncludeHeaderCZP; IncludeHeader)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Include Header';
                        ToolTip = 'Specifies if you also want to copy the information from the document header.';
                    }
                    field(RecalculateLinesCZP; RecalculateLines)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Recalculate Lines';
                        ToolTip = 'Specifies that lines are recalculate and inserted on the cash document you are creating.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if (CashDeskNo <> '') and (DocNo <> '') then begin
                case DocType of
                    DocType::"Cash Document":
                        if FromCashDocumentHeaderCZP.Get(CashDeskNo, DocNo) then
                            ;
                    DocType::"Posted Cash Document":
                        if FromPostedCashDocumentHdrCZP.Get(CashDeskNo, DocNo) then
                            FromCashDocumentHeaderCZP.TransferFields(FromPostedCashDocumentHdrCZP);
                end;
                if FromCashDocumentHeaderCZP."No." = '' then
                    DocNo := '';
            end;
            ValidateDocNo();

            IncludeHeader := true;
            RecalculateLines := true;
        end;
    }

    trigger OnPreReport()
    begin
        CopyCashDocumentMgtCZP.SetProperties(IncludeHeader, RecalculateLines);
        CopyCashDocumentMgtCZP.CopyCashDocument(DocType, CashDeskNo, DocNo, CashDocumentHeaderCZP);
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        FromCashDocumentHeaderCZP: Record "Cash Document Header CZP";
        FromPostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        CopyCashDocumentMgtCZP: Codeunit "Copy Cash Document Mgt. CZP";
        DocType: Option "Cash Document","Posted Cash Document";
        DocNo: Code[20];
        CashDeskNo: Code[20];
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;

    procedure SetCashDocument(var NewCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        NewCashDocumentHeaderCZP.TestField("No.");
        CashDocumentHeaderCZP := NewCashDocumentHeaderCZP;
    end;

    local procedure ValidateDocNo()
    begin
        if (CashDeskNo = '') or (DocNo = '') then
            FromCashDocumentHeaderCZP.Init()
        else
            if FromCashDocumentHeaderCZP."No." = '' then begin
                FromCashDocumentHeaderCZP.Init();
                case DocType of
                    DocType::"Cash Document":
                        FromCashDocumentHeaderCZP.Get(CashDeskNo, DocNo);
                    DocType::"Posted Cash Document":
                        begin
                            FromPostedCashDocumentHdrCZP.Get(CashDeskNo, DocNo);
                            FromCashDocumentHeaderCZP.TransferFields(FromPostedCashDocumentHdrCZP);
                        end;
                end;
            end;
    end;

    local procedure LookupDocNo()
    begin
        case DocType of
            DocType::"Cash Document":
                begin
                    FromCashDocumentHeaderCZP."No." := DocNo;
                    if CashDeskNo <> '' then
                        FromCashDocumentHeaderCZP.SetRange("Cash Desk No.", CashDeskNo);
                    FromCashDocumentHeaderCZP.SetRange("Document Type", CashDocumentHeaderCZP."Document Type");
                    FromCashDocumentHeaderCZP.SetRange("Currency Code", CashDocumentHeaderCZP."Currency Code");
                    if Page.RunModal(0, FromCashDocumentHeaderCZP) = Action::LookupOK then begin
                        CashDeskNo := FromCashDocumentHeaderCZP."Cash Desk No.";
                        DocNo := FromCashDocumentHeaderCZP."No.";
                    end;
                end;
            DocType::"Posted Cash Document":
                begin
                    FromPostedCashDocumentHdrCZP."No." := DocNo;
                    if CashDeskNo <> '' then
                        FromPostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskNo);
                    FromPostedCashDocumentHdrCZP.SetRange("Document Type", CashDocumentHeaderCZP."Document Type");
                    FromPostedCashDocumentHdrCZP.SetRange("Currency Code", CashDocumentHeaderCZP."Currency Code");
                    if Page.RunModal(0, FromPostedCashDocumentHdrCZP) = Action::LookupOK then begin
                        CashDeskNo := FromPostedCashDocumentHdrCZP."Cash Desk No.";
                        DocNo := FromPostedCashDocumentHdrCZP."No.";
                    end;
                end;
        end;
        ValidateDocNo();
    end;

    local procedure ValidateCashDeskNo()
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
    begin
        CashDeskManagementCZP.CheckCashDesk(CashDeskNo);
        ValidateDocNo();
    end;

    procedure InitializeRequest(NewDocType: Option "Cash Document","Posted Cash Document"; NewCashDeskNo: Code[20]; NewDocNo: Code[20])
    begin
        DocType := NewDocType;
        CashDeskNo := NewCashDeskNo;
        DocNo := NewDocNo;
    end;
}
