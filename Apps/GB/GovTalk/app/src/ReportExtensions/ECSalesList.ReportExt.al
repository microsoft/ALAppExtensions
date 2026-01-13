// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using System;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using System.IO;
using System.Utilities;

reportextension 10504 "EC Sales List" extends "EC Sales List"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/ECSalesListGB.rdlc';
#endif
    dataset
    {
        modify("VAT Entry")
        {
            RequestFilterFields = "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT Reporting Date", "EU Service";

            trigger OnBeforePostDataItem()
#if not CLEAN27
            var
                GovTalk: Codeunit GovTalk;
#endif
            begin
#if not CLEAN27
                if not GovTalk.IsEnabled() then
                    exit;
#endif
                UpdateXMLFileRTCGB();
            end;
        }
        add("Country/Region")
        {
            column(IndicatorCodeCaption; Indicator_Code_CaptionLbl)
            {
            }
        }
        add("VAT Entry")
        {
            column(IndicatorCodeGB; IndicatorCode)
            {
            }
        }
    }
    requestpage
    {
        layout
        {
#if not CLEAN27
            modify("Create XML File")
            {
                Visible = false;
            }
#endif
            addafter(ReportLayout)
            {
                field("Create XML File GB"; "Create XML File")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create XML File';
                    ToolTip = 'Specifies the calculated tax and base amounts, and creates the sales VAT advance notification XML document that will be sent to the tax authority.';
#if not CLEAN27
                    Visible = CreateXMLVisible;
#endif

                    trigger OnValidate()
#if not CLEAN27
                    var
                        GovTalk: Codeunit GovTalk;
#endif
                    begin
#if not CLEAN27
                        if not GovTalk.IsEnabled() then
                            exit;
#endif
                        CreateXMLFileOnAfterValidate();
                    end;
                }
            }
        }

        trigger OnOpenPage()
        begin
#if not CLEAN27
            CreateXMLVisible := GovTalk.IsEnabled();
#endif
            XMLFileEnable := "Create XML File";
        end;
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'EC Sales List GB localization';
            LayoutFile = './src/ReportExtensions/ECSalesListGB.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature GovTalk will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    trigger OnPostReport()
    begin
#if not CLEAN27
        if not GovTalk.IsEnabled() then
            exit;
#endif
        if "Create XML File" then
            SaveXMLFileGB();
    end;

    trigger OnPreReport()
    var
        PeriodEnd: Date;
    begin
#if not CLEAN27
        if not GovTalk.IsEnabled() then
            exit;
#endif
        PeriodStart := "VAT Entry".GetRangeMin("Posting Date");
        PeriodEnd := "VAT Entry".GetRangeMax("Posting Date");

        Calendar.Reset();
        Calendar.SetFilter("Period Type", '%1|%2', Calendar."Period Type"::Month, Calendar."Period Type"::Quarter);
        Calendar.SetRange("Period Start", PeriodStart);
        Calendar.SetRange("Period End", ClosingDate(PeriodEnd));
        if not Calendar.FindFirst() then
            Error(Text10500Err, "VAT Entry".FieldCaption("Posting Date"), "VAT Entry".GetFilter("Posting Date"));

        if "Create XML File" then
            CreateXMLDocumentGB();
    end;

    var
        Calendar: Record Date;
#if not CLEAN27
        GovTalk: Codeunit GovTalk;
        CreateXMLVisible: Boolean;
#endif
        XMLOut: DotNet XmlDocument;
        XMLCurrNode: DotNet XmlNode;
        Attribute: DotNet XmlAttribute;
        NewChildNode: DotNet XmlNode;
        NewChildNode2: DotNet XmlNode;
        NewChildNode3: DotNet XmlNode;
        EUTrdPartyAmtGB: Decimal;
        NotEUTrdPartyAmtGB: Decimal;
        NotEUTrdPartyAmtServiceGB: Decimal;
        "XML File": Text;
        "Create XML File": Boolean;
        Text1041000Lbl: Label 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*';
        Text1041001Lbl: Label 'Export to XML File';
        PeriodStart: Date;
        Text1041002Msg: Label 'XML file successfully created';
        Text1040003Lbl: Label 'Default';
        ToFile: Text;
        PrevVATRegNo: Text[30];
        NewGroupStarted: Boolean;
        XMLFileEnable: Boolean;
        Text10500Err: Label '%1 filter %2 must be corrected, to run the report monthly or quarterly. ', Comment = '%1 = posting date, %2 = posting date filter';
        IndicatorCode: Integer;
        Indicator_Code_CaptionLbl: Label 'Indicator Code';

    procedure SetNewGroupStarted(NewGroup: Boolean)
    begin
        NewGroupStarted := NewGroup;
    end;

    procedure SetPrevVATRegNo(VATRegNo: Text[30])
    begin
        PrevVATRegNo := VATRegNo;
    end;

    procedure SetIndicatorCode(Code: Integer)
    begin
        IndicatorCode := Code;
    end;

    procedure SetEUTrdPartyAmt(EUTrdPartyAmt: Decimal)
    begin
        EUTrdPartyAmtGB := EUTrdPartyAmt;
    end;

    procedure SetNotEUTrdPartyAmt(NotEUTrdPartyAmt: Decimal)
    begin
        NotEUTrdPartyAmtGB := NotEUTrdPartyAmt;
    end;

    procedure SetNotEUTrdPartyAmtService(NotEUTrdPartyAmtService: Decimal)
    begin
        NotEUTrdPartyAmtServiceGB := NotEUTrdPartyAmtService;
    end;

    [Scope('OnPrem')]
    procedure CreateXMLDocumentGB()
    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        RBMgt: Codeunit "File Management";
    begin
        CompanyInfo.Get();
        "XML File" := RBMgt.ServerTempFileName('xml');
        XMLOut := XMLOut.XmlDocument();


        XMLCurrNode := XMLOut.CreateElement('Submission');
        Attribute := XMLOut.CreateAttribute('type');
        Attribute.Value := 'HMCE_VAT_ESL_BULK_SUBMISSION_FILE';
        XMLCurrNode.Attributes.SetNamedItem(Attribute);
        XMLOut.AppendChild(XMLCurrNode);

        XMLOut.CreateProcessingInstruction('xml', 'version="1.0" encoding="utf-8"');

        NewChildNode := XMLOut.CreateElement('TraderVRN');
        NewChildNode.InnerText(CompanyInfo."VAT Registration No.");
        XMLCurrNode.AppendChild(NewChildNode);

        NewChildNode := XMLOut.CreateElement('Branch');
        NewChildNode.InnerText(CompanyInfo."Branch Number GB");
        XMLCurrNode.AppendChild(NewChildNode);

        NewChildNode := XMLOut.CreateElement('Year');
        NewChildNode.InnerText(Format(Date2DMY(PeriodStart, 3)));
        XMLCurrNode.AppendChild(NewChildNode);

        NewChildNode := XMLOut.CreateElement('Period');
        NewChildNode.InnerText(FormatPeriodGB(Calendar."Period No." * CalcPeriodValueGB()));
        XMLCurrNode.AppendChild(NewChildNode);

        GLSetup.Get();
        NewChildNode := XMLOut.CreateElement('CurrencyA3');
        NewChildNode.InnerText(GLSetup."LCY Code");
        XMLCurrNode.AppendChild(NewChildNode);

        NewChildNode := XMLOut.CreateElement('ContactName');
        NewChildNode.InnerText(CompanyInfo."Contact Person");
        XMLCurrNode.AppendChild(NewChildNode);

        NewChildNode := XMLOut.CreateElement('Online');
        NewChildNode.InnerText('0');
        XMLCurrNode.AppendChild(NewChildNode);

        NewChildNode := XMLOut.CreateElement('SubmissionLines');
    end;

    [Scope('OnPrem')]
    procedure CreateXMLSubmissionLineGB(Amount: Decimal; IndicatorNo: Integer)
    begin
        NewChildNode2 := XMLOut.CreateElement('SubmissionLine');

        NewChildNode3 := XMLOut.CreateElement('CountryA2');
        NewChildNode3.InnerText("Country/Region"."EU Country/Region Code");

        NewChildNode.AppendChild(NewChildNode2);
        NewChildNode2.AppendChild(NewChildNode3);

        NewChildNode3 := XMLOut.CreateElement('CustomerVRN');
        if NewGroupStarted then
            NewChildNode3.InnerText(PrevVATRegNo)
        else
            NewChildNode3.InnerText("VAT Entry"."VAT Registration No.");
        NewChildNode2.AppendChild(NewChildNode3);

        NewChildNode3 := XMLOut.CreateElement('Value');
        NewChildNode3.InnerText(FormatAmtXML(Amount));
        NewChildNode2.AppendChild(NewChildNode3);
        NewChildNode3 := XMLOut.CreateElement('Indicator');
        NewChildNode3.InnerText(Format(IndicatorNo));
        NewChildNode2.AppendChild(NewChildNode3);
        XMLCurrNode.AppendChild(NewChildNode);
    end;

    [Scope('OnPrem')]
    procedure SaveXMLFileGB()
    begin
        XMLOut.Save("XML File");
        ToFile := Text1040003Lbl + '.xml';
        if not Download("XML File", Text1041001Lbl, '', Text1041000Lbl, ToFile) then
            exit;
        Message(Text1041002Msg);
    end;

    local procedure FormatAmtXML(AmountToPrint: Decimal): Text[30]
    begin
        exit(Format(Round(-AmountToPrint, 1), 0, 1));
    end;

    [Scope('OnPrem')]
    procedure UpdateXMLFileRTCGB()
    var
        IndicatorCode2: Integer;
    begin
        if "Create XML File" and
           (NotEUTrdPartyAmtGB <> 0)
        then begin
            IndicatorCode2 := GetIndicatorCodeGB(false, false);
            CreateXMLSubmissionLineGB(NotEUTrdPartyAmtGB, IndicatorCode2);
        end;

        if "Create XML File" and (NotEUTrdPartyAmtServiceGB <> 0) then begin
            IndicatorCode2 := GetIndicatorCodeGB(false, true);
            CreateXMLSubmissionLineGB(NotEUTrdPartyAmtServiceGB, IndicatorCode2);
        end;
        if "Create XML File" and
           (EUTrdPartyAmtGB <> 0)
        then begin
            IndicatorCode2 := GetIndicatorCodeGB(true, false);
            CreateXMLSubmissionLineGB(EUTrdPartyAmtGB, IndicatorCode2);
        end;
    end;

    local procedure CreateXMLFileOnAfterValidate()
    begin
        XMLFileEnable := "Create XML File";
    end;

    [Scope('OnPrem')]
    procedure CalcPeriodValueGB(): Integer
    begin
        if Calendar."Period Type" = Calendar."Period Type"::Month then
            exit(1)
        else
            exit(3)
    end;

    [Scope('OnPrem')]
    procedure FormatPeriodGB(PeriodNo: Integer): Text[30]
    begin
        exit(Format(PeriodNo, 2, '<Integer,2><Filler Character,0>'));
    end;

    [Scope('OnPrem')]
    procedure GetIndicatorCodeGB(EU3rdPartyTrade: Boolean; EUService: Boolean): Integer
    begin
        if EUService then
            exit(3)
        else
            if EU3rdPartyTrade then
                exit(2)
            else
                exit(0)
    end;
}