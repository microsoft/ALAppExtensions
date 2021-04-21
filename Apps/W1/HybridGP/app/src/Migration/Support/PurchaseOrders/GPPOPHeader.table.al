table 40102 "GP POPPOHeader"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; PONUMBER; Text[18])
        {
            Caption = 'PONUMBER';
            DataClassification = CustomerContent;
        }
        field(2; POSTATUS; Option)
        {
            Caption = 'POSTATUS';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(3; STATGRP; Integer)
        {
            Caption = 'STATGRP';
            DataClassification = CustomerContent;
        }
        field(4; POTYPE; Option)
        {
            Caption = 'POTYPE';
            OptionMembers = ,"Standard","Drop-Ship","Blanket","Drop-Ship Blanket";
            DataClassification = CustomerContent;
        }
        field(5; USER2ENT; Text[16])
        {
            Caption = 'USER2ENT';
            DataClassification = CustomerContent;
        }
        field(6; CONFIRM1; Text[22])
        {
            Caption = 'CONFIRM1';
            DataClassification = CustomerContent;
        }
        field(7; DOCDATE; Date)
        {
            Caption = 'DOCDATE';
            DataClassification = CustomerContent;
        }
        field(8; LSTEDTDT; Date)
        {
            Caption = 'LSTEDTDT';
            DataClassification = CustomerContent;
        }
        field(9; LSTPRTDT; Date)
        {
            Caption = 'LSTPRTDT';
            DataClassification = CustomerContent;
        }
        field(10; PRMDATE; Date)
        {
            Caption = 'PRMDATE';
            DataClassification = CustomerContent;
        }
        field(11; PRMSHPDTE; Date)
        {
            Caption = 'PRMSHPDTE';
            DataClassification = CustomerContent;
        }
        field(12; REQDATE; Date)
        {
            Caption = 'REQDATE';
            DataClassification = CustomerContent;
        }
        field(13; REQTNDT; Date)
        {
            Caption = 'REQTNDT';
            DataClassification = CustomerContent;
        }
        field(14; SHIPMTHD; Text[16])
        {
            Caption = 'SHIPMTHD';
            DataClassification = CustomerContent;
        }
        field(15; TXRGNNUM; Text[26])
        {
            Caption = 'TXRGNNUM';
            DataClassification = CustomerContent;
        }
        field(16; REMSUBTO; Decimal)
        {
            Caption = 'REMSUBTO';
            DataClassification = CustomerContent;
        }
        field(17; SUBTOTAL; Decimal)
        {
            Caption = 'SUBTOTAL';
            DataClassification = CustomerContent;
        }
        field(18; TRDISAMT; Decimal)
        {
            Caption = 'TRDISAMT';
            DataClassification = CustomerContent;
        }
        field(19; FRTAMNT; Decimal)
        {
            Caption = 'FRTAMNT';
            DataClassification = CustomerContent;
        }
        field(20; MSCCHAMT; Decimal)
        {
            Caption = 'MSCCHAMT';
            DataClassification = CustomerContent;
        }
        field(21; TAXAMNT; Decimal)
        {
            Caption = 'TAXAMNT';
            DataClassification = CustomerContent;
        }
        field(22; VENDORID; Text[16])
        {
            Caption = 'VENDORID';
            DataClassification = CustomerContent;
        }
        field(23; VENDNAME; Text[66])
        {
            Caption = 'VENDNAME';
            DataClassification = CustomerContent;
        }
        field(24; MINORDER; Decimal)
        {
            Caption = 'MINORDER';
            DataClassification = CustomerContent;
        }
        field(25; VADCDPAD; Text[16])
        {
            Caption = 'VADCDPAD';
            DataClassification = CustomerContent;
        }
        field(26; CMPANYID; Integer)
        {
            Caption = 'CMPANYID';
            DataClassification = CustomerContent;
        }
        field(27; PRBTADCD; Text[16])
        {
            Caption = 'PRBTADCD';
            DataClassification = CustomerContent;
        }
        field(28; PRSTADCD; Text[16])
        {
            Caption = 'PRSTADCD';
            DataClassification = CustomerContent;
        }
        field(29; CMPNYNAM; Text[66])
        {
            Caption = 'CMPNYNAM';
            DataClassification = CustomerContent;
        }
        field(30; CONTACT; Text[62])
        {
            Caption = 'CONTACT';
            DataClassification = CustomerContent;
        }
        field(31; ADDRESS1; Text[62])
        {
            Caption = 'ADDRESS1';
            DataClassification = CustomerContent;
        }
        field(32; ADDRESS2; Text[62])
        {
            Caption = 'ADDRESS2';
            DataClassification = CustomerContent;
        }
        field(33; ADDRESS3; Text[62])
        {
            Caption = 'ADDRESS3';
            DataClassification = CustomerContent;
        }
        field(34; CITY; Text[36])
        {
            Caption = 'CITY';
            DataClassification = CustomerContent;
        }
        field(35; STATE; Text[30])
        {
            Caption = 'STATE';
            DataClassification = CustomerContent;
        }
        field(36; ZIPCODE; Text[12])
        {
            Caption = 'ZIPCODE';
            DataClassification = CustomerContent;
        }
        field(37; CCode; Text[8])
        {
            Caption = 'CCode';
            DataClassification = CustomerContent;
        }
        field(38; COUNTRY; Text[62])
        {
            Caption = 'COUNTRY';
            DataClassification = CustomerContent;
        }
        field(39; PHONE1; Text[22])
        {
            Caption = 'PHONE1';
            DataClassification = CustomerContent;
        }
        field(40; PHONE2; Text[22])
        {
            Caption = 'PHONE2';
            DataClassification = CustomerContent;
        }
        field(41; PHONE3; Text[22])
        {
            Caption = 'PHONE3';
            DataClassification = CustomerContent;
        }
        field(42; FAX; Text[22])
        {
            Caption = 'FAX';
            DataClassification = CustomerContent;
        }
        field(43; PYMTRMID; Text[22])
        {
            Caption = 'PYMTRMID';
            DataClassification = CustomerContent;
        }
        field(44; DSCDLRAM; Decimal)
        {
            Caption = 'DSCDLRAM';
            DataClassification = CustomerContent;
        }
        field(45; DSCPCTAM; Integer)
        {
            Caption = 'DSCPCTAM';
            DataClassification = CustomerContent;
        }
        field(46; DISAMTAV; Decimal)
        {
            Caption = 'DISAMTAV';
            DataClassification = CustomerContent;
        }
        field(47; DISCDATE; Date)
        {
            Caption = 'DISCDATE';
            DataClassification = CustomerContent;
        }
        field(48; DUEDATE; Date)
        {
            Caption = 'DUEDATE';
            DataClassification = CustomerContent;
        }
        field(49; TRDPCTPR; Text[25])
        {
            Caption = 'TRDPCTPR';
            DataClassification = CustomerContent;
        }
        field(50; CUSTNMBR; Text[16])
        {
            Caption = 'CUSTNMBR';
            DataClassification = CustomerContent;
        }
        field(51; TIMESPRT; Integer)
        {
            Caption = 'TIMESPRT';
            DataClassification = CustomerContent;
        }
        field(52; CREATDDT; Date)
        {
            Caption = 'CREATDDT';
            DataClassification = CustomerContent;
        }
        field(53; MODIFDT; Date)
        {
            Caption = 'MODIFDT';
            DataClassification = CustomerContent;
        }
        field(54; PONOTIDS_1; Decimal)
        {
            Caption = 'PONOTIDS_1';
            DataClassification = CustomerContent;
        }
        field(55; PONOTIDS_2; Decimal)
        {
            Caption = 'PONOTIDS_2';
            DataClassification = CustomerContent;
        }
        field(56; PONOTIDS_3; Decimal)
        {
            Caption = 'PONOTIDS_3';
            DataClassification = CustomerContent;
        }
        field(57; PONOTIDS_4; Decimal)
        {
            Caption = 'PONOTIDS_4';
            DataClassification = CustomerContent;
        }
        field(58; PONOTIDS_5; Decimal)
        {
            Caption = 'PONOTIDS_5';
            DataClassification = CustomerContent;
        }
        field(59; PONOTIDS_6; Decimal)
        {
            Caption = 'PONOTIDS_6';
            DataClassification = CustomerContent;
        }
        field(60; PONOTIDS_7; Decimal)
        {
            Caption = 'PONOTIDS_7';
            DataClassification = CustomerContent;
        }
        field(61; PONOTIDS_8; Decimal)
        {
            Caption = 'PONOTIDS_8';
            DataClassification = CustomerContent;
        }
        field(62; PONOTIDS_9; Decimal)
        {
            Caption = 'PONOTIDS_9';
            DataClassification = CustomerContent;
        }
        field(63; PONOTIDS_10; Decimal)
        {
            Caption = 'PONOTIDS_10';
            DataClassification = CustomerContent;
        }
        field(64; PONOTIDS_11; Decimal)
        {
            Caption = 'PONOTIDS_11';
            DataClassification = CustomerContent;
        }
        field(65; PONOTIDS_12; Decimal)
        {
            Caption = 'PONOTIDS_12';
            DataClassification = CustomerContent;
        }
        field(66; PONOTIDS_13; Decimal)
        {
            Caption = 'PONOTIDS_13';
            DataClassification = CustomerContent;
        }
        field(67; PONOTIDS_14; Decimal)
        {
            Caption = 'PONOTIDS_14';
            DataClassification = CustomerContent;
        }
        field(68; PONOTIDS_15; Decimal)
        {
            Caption = 'PONOTIDS_15';
            DataClassification = CustomerContent;
        }
        field(69; COMMNTID; Text[16])
        {
            Caption = 'COMMNTID';
            DataClassification = CustomerContent;
        }
        field(70; CANCSUB; Decimal)
        {
            Caption = 'CANCSUB';
            DataClassification = CustomerContent;
        }
        field(71; CURNCYID; Text[16])
        {
            Caption = 'CURNCYID';
            DataClassification = CustomerContent;
        }
        field(72; CURRNIDX; Integer)
        {
            Caption = 'CURRNIDX';
            DataClassification = CustomerContent;
        }
        field(73; RATETPID; Text[16])
        {
            Caption = 'RATETPID';
            DataClassification = CustomerContent;
        }
        field(74; EXGTBLID; Text[16])
        {
            Caption = 'EXGTBLID';
            DataClassification = CustomerContent;
        }
        field(75; XCHGRATE; Decimal)
        {
            Caption = 'XCHGRATE';
            DataClassification = CustomerContent;
        }
        field(76; EXCHDATE; Date)
        {
            Caption = 'EXCHDATE';
            DataClassification = CustomerContent;
        }
        field(77; TIME1; Date)
        {
            Caption = 'TIME1';
            DataClassification = CustomerContent;
        }
        field(78; RATECALC; Integer)
        {
            Caption = 'RATECALC';
            DataClassification = CustomerContent;
        }
        field(79; DENXRATE; Decimal)
        {
            Caption = 'DENXRATE';
            DataClassification = CustomerContent;
        }
        field(80; MCTRXSTT; Integer)
        {
            Caption = 'MCTRXSTT';
            DataClassification = CustomerContent;
        }
        field(81; OREMSUBT; Decimal)
        {
            Caption = 'OREMSUBT';
            DataClassification = CustomerContent;
        }
        field(82; ORSUBTOT; Decimal)
        {
            Caption = 'ORSUBTOT';
            DataClassification = CustomerContent;
        }
        field(83; Originating_Canceled_Sub; Decimal)
        {
            Caption = 'Originating_Canceled_Sub';
            DataClassification = CustomerContent;
        }
        field(84; ORTDISAM; Decimal)
        {
            Caption = 'ORTDISAM';
            DataClassification = CustomerContent;
        }
        field(85; ORFRTAMT; Decimal)
        {
            Caption = 'ORFRTAMT';
            DataClassification = CustomerContent;
        }
        field(86; OMISCAMT; Decimal)
        {
            Caption = 'OMISCAMT';
            DataClassification = CustomerContent;
        }
        field(87; ORTAXAMT; Decimal)
        {
            Caption = 'ORTAXAMT';
            DataClassification = CustomerContent;
        }
        field(88; ORDDLRAT; Decimal)
        {
            Caption = 'ORDDLRAT';
            DataClassification = CustomerContent;
        }
        field(89; ODISAMTAV; Decimal)
        {
            Caption = 'ODISAMTAV';
            DataClassification = CustomerContent;
        }
        field(90; BUYERID; Text[16])
        {
            Caption = 'BUYERID';
            DataClassification = CustomerContent;
        }
        field(91; ONORDAMT; Decimal)
        {
            Caption = 'ONORDAMT';
            DataClassification = CustomerContent;
        }
        field(92; ORORDAMT; Decimal)
        {
            Caption = 'ORORDAMT';
            DataClassification = CustomerContent;
        }
        field(93; HOLD; Boolean)
        {
            Caption = 'HOLD';
            DataClassification = CustomerContent;
        }
        field(94; ONHOLDDATE; Date)
        {
            Caption = 'ONHOLDDATE';
            DataClassification = CustomerContent;
        }
        field(95; ONHOLDBY; Text[16])
        {
            Caption = 'ONHOLDBY';
            DataClassification = CustomerContent;
        }
        field(96; HOLDREMOVEDATE; Date)
        {
            Caption = 'HOLDREMOVEDATE';
            DataClassification = CustomerContent;
        }
        field(97; HOLDREMOVEBY; Text[16])
        {
            Caption = 'HOLDREMOVEBY';
            DataClassification = CustomerContent;
        }
        field(98; ALLOWSOCMTS; Boolean)
        {
            Caption = 'ALLOWSOCMTS';
            DataClassification = CustomerContent;
        }
        field(99; DISGRPER; Integer)
        {
            Caption = 'DISGRPER';
            DataClassification = CustomerContent;
        }
        field(100; DUEGRPER; Integer)
        {
            Caption = 'DUEGRPER';
            DataClassification = CustomerContent;
        }
        field(101; Revision_Number; Integer)
        {
            Caption = 'Revision_Number';
            DataClassification = CustomerContent;
        }
        field(102; Change_Order_Flag; Integer)
        {
            Caption = 'Change_Order_Flag';
            DataClassification = CustomerContent;
        }
        field(103; PO_Field_Changes; Blob)
        {
            Caption = 'PO_Field_Changes';
            DataClassification = CustomerContent;
        }
        field(104; PO_Status_Orig; Option)
        {
            Caption = 'PO_Status_Orig';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(105; TAXSCHID; Text[16])
        {
            Caption = 'TAXSCHID';
            DataClassification = CustomerContent;
        }
        field(106; TXSCHSRC; Integer)
        {
            Caption = 'TXSCHSRC';
            DataClassification = CustomerContent;
        }
        field(107; TXENGCLD; Boolean)
        {
            Caption = 'TXENGCLD';
            DataClassification = CustomerContent;
        }
        field(108; BSIVCTTL; Boolean)
        {
            Caption = 'BSIVCTTL';
            DataClassification = CustomerContent;
        }
        field(109; Purchase_Freight_Taxable; Option)
        {
            Caption = 'Purchase_Freight_Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(110; Purchase_Misc_Taxable; Option)
        {
            Caption = 'Purchase_Misc_Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(111; FRTSCHID; Text[16])
        {
            Caption = 'FRTSCHID';
            DataClassification = CustomerContent;
        }
        field(112; MSCSCHID; Text[16])
        {
            Caption = 'MSCSCHID';
            DataClassification = CustomerContent;
        }
        field(113; FRTTXAMT; Decimal)
        {
            Caption = 'FRTTXAMT';
            DataClassification = CustomerContent;
        }
        field(114; ORFRTTAX; Decimal)
        {
            Caption = 'ORFRTTAX';
            DataClassification = CustomerContent;
        }
        field(115; MSCTXAMT; Decimal)
        {
            Caption = 'MSCTXAMT';
            DataClassification = CustomerContent;
        }
        field(116; ORMSCTAX; Decimal)
        {
            Caption = 'ORMSCTAX';
            DataClassification = CustomerContent;
        }
        field(117; BCKTXAMT; Decimal)
        {
            Caption = 'BCKTXAMT';
            DataClassification = CustomerContent;
        }
        field(118; OBTAXAMT; Decimal)
        {
            Caption = 'OBTAXAMT';
            DataClassification = CustomerContent;
        }
        field(119; BackoutFreightTaxAmt; Decimal)
        {
            Caption = 'BackoutFreightTaxAmt';
            DataClassification = CustomerContent;
        }
        field(120; OrigBackoutFreightTaxAmt; Decimal)
        {
            Caption = 'OrigBackoutFreightTaxAmt';
            DataClassification = CustomerContent;
        }
        field(121; BackoutMiscTaxAmt; Decimal)
        {
            Caption = 'BackoutMiscTaxAmt';
            DataClassification = CustomerContent;
        }
        field(122; OrigBackoutMiscTaxAmt; Decimal)
        {
            Caption = 'OrigBackoutMiscTaxAmt';
            DataClassification = CustomerContent;
        }
        field(123; Flags; Integer)
        {
            Caption = 'Flags';
            DataClassification = CustomerContent;
        }
        field(124; BackoutTradeDiscTax; Decimal)
        {
            Caption = 'BackoutTradeDiscTax';
            DataClassification = CustomerContent;
        }
        field(125; OrigBackoutTradeDiscTax; Decimal)
        {
            Caption = 'OrigBackoutTradeDiscTax';
            DataClassification = CustomerContent;
        }
        field(126; POPCONTNUM; Text[22])
        {
            Caption = 'POPCONTNUM';
            DataClassification = CustomerContent;
        }
        field(127; CONTENDDTE; Date)
        {
            Caption = 'CONTENDDTE';
            DataClassification = CustomerContent;
        }
        field(128; CNTRLBLKTBY; Integer)
        {
            Caption = 'CNTRLBLKTBY';
            DataClassification = CustomerContent;
        }
        field(129; PURCHCMPNYNAM; Text[66])
        {
            Caption = 'PURCHCMPNYNAM';
            DataClassification = CustomerContent;
        }
        field(130; PURCHCONTACT; Text[62])
        {
            Caption = 'PURCHCONTACT';
            DataClassification = CustomerContent;
        }
        field(131; PURCHADDRESS1; Text[62])
        {
            Caption = 'PURCHADDRESS1';
            DataClassification = CustomerContent;
        }
        field(132; PURCHADDRESS2; Text[62])
        {
            Caption = 'PURCHADDRESS2';
            DataClassification = CustomerContent;
        }
        field(133; PURCHADDRESS3; Text[62])
        {
            Caption = 'PURCHADDRESS3';
            DataClassification = CustomerContent;
        }
        field(134; PURCHCITY; Text[36])
        {
            Caption = 'PURCHCITY';
            DataClassification = CustomerContent;
        }
        field(135; PURCHSTATE; Text[30])
        {
            Caption = 'PURCHSTATE';
            DataClassification = CustomerContent;
        }
        field(136; PURCHZIPCODE; Text[12])
        {
            Caption = 'PURCHZIPCODE';
            DataClassification = CustomerContent;
        }
        field(137; PURCHCCode; Text[8])
        {
            Caption = 'PURCHCCode';
            DataClassification = CustomerContent;
        }
        field(138; PURCHCOUNTRY; Text[62])
        {
            Caption = 'PURCHCOUNTRY';
            DataClassification = CustomerContent;
        }
        field(139; PURCHPHONE1; Text[22])
        {
            Caption = 'PURCHPHONE1';
            DataClassification = CustomerContent;
        }
        field(140; PURCHPHONE2; Text[22])
        {
            Caption = 'PURCHPHONE2';
            DataClassification = CustomerContent;
        }
        field(141; PURCHPHONE3; Text[22])
        {
            Caption = 'PURCHPHONE3';
            DataClassification = CustomerContent;
        }
        field(142; PURCHFAX; Text[22])
        {
            Caption = 'PURCHFAX';
            DataClassification = CustomerContent;
        }
        field(143; BLNKTLINEEXTQTYSUM; Decimal)
        {
            Caption = 'BLNKTLINEEXTQTYSUM';
            DataClassification = CustomerContent;
        }
        field(144; CBVAT; Boolean)
        {
            Caption = 'CBVAT';
            DataClassification = CustomerContent;
        }
        field(145; Workflow_Approval_Status; Option)
        {
            Caption = 'Workflow_Approval_Status';
            OptionMembers = ,"Not Submitted","Submitted","Not Needed","Pending Approval","Pending Changes","Approved","Rejected","Ended","Not Activated","Deactivated";
            DataClassification = CustomerContent;
        }
        field(146; Workflow_Priority; Option)
        {
            Caption = 'Workflow_Priority';
            OptionMembers = ,"Low","Normal","High";
            DataClassification = CustomerContent;
        }
        field(147; Workflow_Status; Option)
        {
            Caption = 'Workflow_Status';
            OptionMembers = ,"Not Submitted","Submitted (Depriciated)","No Action Needed","Pending User Action","Recalled","Completed","Rejected","Workflow Ended (Depriciated)","Not Activated","Deactivated (Depricated)";
            DataClassification = CustomerContent;
        }
        field(148; Print_Phone_NumberGB; Integer)
        {
            Caption = 'Print_Phone_NumberGB';
            DataClassification = CustomerContent;
        }
        field(149; PrepaymentAmount; Decimal)
        {
            Caption = 'PrepaymentAmount';
            DataClassification = CustomerContent;
        }
        field(150; OriginatingPrepaymentAmt; Decimal)
        {
            Caption = 'OriginatingPrepaymentAmt';
            DataClassification = CustomerContent;
        }
        field(151; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(152; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PONUMBER)
        {
            Clustered = true;
        }
    }

    var
        PostingDescriptionTxt: Label 'Migrated from GP';
        PostingGroupTxt: Label 'GP', Locked = true;

    procedure MoveStagingData()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CompanyInformation: Record "Company Information";
        PurchaseHeader: Record "Purchase Header";
        GPPOPPOLine: Record "GP POPPOLine";
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseDocumentStatus: Enum "Purchase Document Status";
        CountryCode: Code[10];
    begin
        if FindSet() then begin
            CountryCode := CompanyInformation."Country/Region Code";
            repeat
                if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PONUMBER) then begin
                    PurchaseHeader.Init();
                    PurchaseHeader."Document Type" := PurchaseDocumentType::Order;
                    PurchaseHeader."No." := PONUMBER;
                    PurchaseHeader.Status := PurchaseDocumentStatus::Open;
                    PurchaseHeader.Insert(true);

                    PurchaseHeader.Validate("Buy-from Vendor No.", VENDORID);
                    PurchaseHeader.Validate("Pay-to Vendor No.", VENDORID);
                    PurchaseHeader.Validate("Order Date", DOCDATE);
                    PurchaseHeader.Validate("Posting Date", DOCDATE);
                    PurchaseHeader.Validate("Document Date", DOCDATE);
                    PurchaseHeader.Validate("Expected Receipt Date", PRMDATE);
                    PurchaseHeader."Posting Description" := PostingDescriptionTxt;
                    PurchaseHeader.Validate("Payment Terms Code", CopyStr(PYMTRMID, 1, 10));
                    PurchaseHeader."Shipment Method Code" := CopyStr(SHIPMTHD, 1, 10);
                    PurchaseHeader."Vendor Posting Group" := PostingGroupTxt;
                    PurchaseHeader.Validate("Prices Including VAT", false);
                    PurchaseHeader.Validate("Vendor Invoice No.", PONUMBER);
                    PurchaseHeader.Validate("Gen. Bus. Posting Group", PostingGroupTxt);
                    UpdateShipToAddress(CountryCode, PurchaseHeader);

                    if PurchasesPayablesSetup.FindFirst() then begin
                        PurchaseHeader.Validate("Posting No. Series", PurchasesPayablesSetup."Posted Invoice Nos.");
                        PurchaseHeader.Validate("Receiving No. Series", PurchasesPayablesSetup."Posted Receipt Nos.");
                    end;

                    PurchaseHeader.Modify(true);
                    GPPOPPOLine.MoveStagingData(PONUMBER);
                end;
            until Next() = 0;
        end;
    end;

    local procedure UpdateShipToAddress(CountryCode: Code[10]; var PurchaseHeader: Record "Purchase Header")
    begin
        if PRSTADCD.Trim() <> '' then begin
            PurchaseHeader."Ship-to Code" := CopyStr(DelChr(PRSTADCD, '>', ' '), 1, 10);
            PurchaseHeader."Ship-to Country/Region Code" := CountryCode;
        end;
        if CMPNYNAM.Trim() <> '' then
            PurchaseHeader."Ship-to Name" := CMPNYNAM;
        if ADDRESS1.Trim() <> '' then
            PurchaseHeader."Ship-to Address" := ADDRESS1;
        if ADDRESS2.Trim() <> '' then
            PurchaseHeader."Ship-to Address 2" := CopyStr(DelChr(ADDRESS2, '>', ' '), 1, 50);
        if CITY.Trim() <> '' then
            PurchaseHeader."Ship-to City" := CopyStr(DelChr(CITY, '>', ' '), 1, 30);
        if CONTACT.Trim() <> '' then
            PurchaseHeader."Ship-to Contact" := CONTACT;
        if ZIPCODE.Trim() <> '' then
            PurchaseHeader."Ship-to Post Code" := ZIPCODE;
        if STATE.Trim() <> '' then
            PurchaseHeader."Ship-to County" := STATE;
    end;
}