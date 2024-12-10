codeunit 17170 "Create BAS XML ID AU"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoAUBAS: Codeunit "Contoso AU BAS";
    begin
        ContosoAUBAS.InsertBASXMLFieldID(ABN(), 2);
        ContosoAUBAS.InsertBASXMLFieldID(ATOCALCULATEDAMOUNT(), 66);
        ContosoAUBAS.InsertBASXMLFieldID(ATOGSTINSTALMENTAMOUNT(), 60);
        ContosoAUBAS.InsertBASXMLFieldID(CALG12(), 43);
        ContosoAUBAS.InsertBASXMLFieldID(CALG13(), 44);
        ContosoAUBAS.InsertBASXMLFieldID(CALG14(), 45);
        ContosoAUBAS.InsertBASXMLFieldID(CALG15(), 46);
        ContosoAUBAS.InsertBASXMLFieldID(CALG16(), 47);
        ContosoAUBAS.InsertBASXMLFieldID(CALG17(), 48);
        ContosoAUBAS.InsertBASXMLFieldID(CALG18(), 49);
        ContosoAUBAS.InsertBASXMLFieldID(CALG19(), 50);
        ContosoAUBAS.InsertBASXMLFieldID(CALG20(), 51);
        ContosoAUBAS.InsertBASXMLFieldID(CALG4(), 29);
        ContosoAUBAS.InsertBASXMLFieldID(CALG5(), 30);
        ContosoAUBAS.InsertBASXMLFieldID(CALG6(), 31);
        ContosoAUBAS.InsertBASXMLFieldID(CALG7(), 32);
        ContosoAUBAS.InsertBASXMLFieldID(CALG8(), 33);
        ContosoAUBAS.InsertBASXMLFieldID(CALG9(), 34);
        ContosoAUBAS.InsertBASXMLFieldID(CALCULATEDINSTALMENTAMOUNT(), 69);
        ContosoAUBAS.InsertBASXMLFieldID(CAPITALPURCHASES(), 41);
        ContosoAUBAS.InsertBASXMLFieldID(COMMISSIONERSINSTALMENTRATE(), 54);
        ContosoAUBAS.InsertBASXMLFieldID(CREDITFROMREDUCEDFBTINSTALMENTS(), 24);
        ContosoAUBAS.InsertBASXMLFieldID(CREDITFROMREDUCEDPAYGINSTALMENTS(), 23);
        ContosoAUBAS.InsertBASXMLFieldID(DIN(), 1);
        ContosoAUBAS.InsertBASXMLFieldID(ESTIMATEDFBTTAX(), 40);
        ContosoAUBAS.InsertBASXMLFieldID(ESTIMATEDGSTFORYEAR(), 61);
        ContosoAUBAS.InsertBASXMLFieldID(ESTIMATEDYEARINCOMETAX(), 67);
        ContosoAUBAS.InsertBASXMLFieldID(EXPORTS(), 27);
        ContosoAUBAS.InsertBASXMLFieldID(FBTINSTALMENT(), 14);
        ContosoAUBAS.InsertBASXMLFieldID(FORMDUEON(), 5);
        ContosoAUBAS.InsertBASXMLFieldID(GSTINSTALMENTS(), 64);
        ContosoAUBAS.InsertBASXMLFieldID(GSTREASONFORVARIATION(), 63);
        ContosoAUBAS.InsertBASXMLFieldID(GSTREFUND(), 18);
        ContosoAUBAS.InsertBASXMLFieldID(GSTTAX(), 7);
        ContosoAUBAS.InsertBASXMLFieldID(GSTTOTALSALES(), 26);
        ContosoAUBAS.InsertBASXMLFieldID(INSTALMENTINCOME(), 37);
        ContosoAUBAS.InsertBASXMLFieldID(LUXURYCARTAXPAYABLE(), 9);
        ContosoAUBAS.InsertBASXMLFieldID(LUXURYCARTAXREFUNDABLE(), 20);
        ContosoAUBAS.InsertBASXMLFieldID(NETAMOUNTFORTHISSTATEMENT(), 17);
        ContosoAUBAS.InsertBASXMLFieldID(NONCAPITALPURCHASES(), 42);
        ContosoAUBAS.InsertBASXMLFieldID(OTHERGSTFREESUPPLIES(), 28);
        ContosoAUBAS.InsertBASXMLFieldID(PAYGINSTALMENT(), 13);
        ContosoAUBAS.InsertBASXMLFieldID(PAYGWITHHOLDING(), 12);
        ContosoAUBAS.InsertBASXMLFieldID(PAYGIOPTION1(), 70);
        ContosoAUBAS.InsertBASXMLFieldID(PAYGIOPTION2(), 71);
        ContosoAUBAS.InsertBASXMLFieldID(PAYMENTDUEON(), 6);
        ContosoAUBAS.InsertBASXMLFieldID(PERIODDATEFROM(), 3);
        ContosoAUBAS.InsertBASXMLFieldID(PERIODDATETO(), 4);
        ContosoAUBAS.InsertBASXMLFieldID(REASONFORFBTVARIATION(), 57);
        ContosoAUBAS.InsertBASXMLFieldID(REASONVARIATION(), 55);
        ContosoAUBAS.InsertBASXMLFieldID(TOTALCREDITS(), 25);
        ContosoAUBAS.InsertBASXMLFieldID(TOTALDEBITS(), 16);
        ContosoAUBAS.InsertBASXMLFieldID(TOTALPAYMENTSWITHHOLDINGAMOUNT(), 36);
        ContosoAUBAS.InsertBASXMLFieldID(TOTALWITHHELDAMOUNT(), 65);
        ContosoAUBAS.InsertBASXMLFieldID(VARIEDFBTINSTALMENT(), 56);
        ContosoAUBAS.InsertBASXMLFieldID(VARIEDGSTINSTALMENT(), 62);
        ContosoAUBAS.InsertBASXMLFieldID(VARIEDINSTALMENT(), 68);
        ContosoAUBAS.InsertBASXMLFieldID(VARIEDINSTALMENTRATE(), 38);
        ContosoAUBAS.InsertBASXMLFieldID(WINEEQUALISATIONTAXPAYABLE(), 8);
        ContosoAUBAS.InsertBASXMLFieldID(WINEEQUALISATIONTAXREFUNDABLE(), 19);
        ContosoAUBAS.InsertBASXMLFieldID(WITHHELDFROMINVESTMENTDISTRIBUTIONSAMOUNT(), 52);
        ContosoAUBAS.InsertBASXMLFieldID(WITHHELDFROMINVOICESNOABN(), 53);
        ContosoAUBAS.InsertBASXMLFieldID(WITHHELDFROMSALARYAMOUNT(), 35);
    end;

    procedure ABN(): Text[80]
    begin
        exit(ABNTok);
    end;

    procedure ATOCALCULATEDAMOUNT(): Text[80]
    begin
        exit(ATOCALCULATEDAMOUNTTok);
    end;

    procedure ATOGSTINSTALMENTAMOUNT(): Text[80]
    begin
        exit(ATOGSTINSTALMENTAMOUNTTok);
    end;

    procedure CALG12(): Text[80]
    begin
        exit(CALG12Tok);
    end;

    procedure CALG13(): Text[80]
    begin
        exit(CALG13Tok);
    end;

    procedure CALG14(): Text[80]
    begin
        exit(CALG14Tok);
    end;

    procedure CALG15(): Text[80]
    begin
        exit(CALG15Tok);
    end;

    procedure CALG16(): Text[80]
    begin
        exit(CALG16Tok);
    end;

    procedure CALG17(): Text[80]
    begin
        exit(CALG17Tok);
    end;

    procedure CALG18(): Text[80]
    begin
        exit(CALG18Tok);
    end;

    procedure CALG19(): Text[80]
    begin
        exit(CALG19Tok);
    end;

    procedure CALG20(): Text[80]
    begin
        exit(CALG20Tok);
    end;

    procedure CALG4(): Text[80]
    begin
        exit(CALG4Tok);
    end;

    procedure CALG5(): Text[80]
    begin
        exit(CALG5Tok);
    end;

    procedure CALG6(): Text[80]
    begin
        exit(CALG6Tok);
    end;

    procedure CALG7(): Text[80]
    begin
        exit(CALG7Tok);
    end;

    procedure CALG8(): Text[80]
    begin
        exit(CALG8Tok);
    end;

    procedure CALG9(): Text[80]
    begin
        exit(CALG9Tok);
    end;

    procedure CALCULATEDINSTALMENTAMOUNT(): Text[80]
    begin
        exit(CALCULATEDINSTALMENTAMOUNTTok);
    end;

    procedure CAPITALPURCHASES(): Text[80]
    begin
        exit(CAPITALPURCHASESTok);
    end;

    procedure COMMISSIONERSINSTALMENTRATE(): Text[80]
    begin
        exit(COMMISSIONERSINSTALMENTRATETok);
    end;

    procedure CREDITFROMREDUCEDFBTINSTALMENTS(): Text[80]
    begin
        exit(CREDITFROMREDUCEDFBTINSTALMENTSTok);
    end;

    procedure CREDITFROMREDUCEDPAYGINSTALMENTS(): Text[80]
    begin
        exit(CREDITFROMREDUCEDPAYGINSTALMENTSTok);
    end;

    procedure DIN(): Text[80]
    begin
        exit(DINTok);
    end;

    procedure ESTIMATEDFBTTAX(): Text[80]
    begin
        exit(ESTIMATEDFBTTAXTok);
    end;

    procedure ESTIMATEDGSTFORYEAR(): Text[80]
    begin
        exit(ESTIMATEDGSTFORYEARTok);
    end;

    procedure ESTIMATEDYEARINCOMETAX(): Text[80]
    begin
        exit(ESTIMATEDYEARINCOMETAXTok);
    end;

    procedure EXPORTS(): Text[80]
    begin
        exit(EXPORTSTok);
    end;

    procedure FBTINSTALMENT(): Text[80]
    begin
        exit(FBTINSTALMENTTok);
    end;

    procedure FORMDUEON(): Text[80]
    begin
        exit(FORMDUEONTok);
    end;

    procedure GSTINSTALMENTS(): Text[80]
    begin
        exit(GSTINSTALMENTSTok);
    end;

    procedure GSTREASONFORVARIATION(): Text[80]
    begin
        exit(GSTREASONFORVARIATIONTok);
    end;

    procedure GSTREFUND(): Text[80]
    begin
        exit(GSTREFUNDTok);
    end;

    procedure GSTTAX(): Text[80]
    begin
        exit(GSTTAXTok);
    end;

    procedure GSTTOTALSALES(): Text[80]
    begin
        exit(GSTTOTALSALESTok);
    end;

    procedure INSTALMENTINCOME(): Text[80]
    begin
        exit(INSTALMENTINCOMETok);
    end;

    procedure LUXURYCARTAXPAYABLE(): Text[80]
    begin
        exit(LUXURYCARTAXPAYABLETok);
    end;

    procedure LUXURYCARTAXREFUNDABLE(): Text[80]
    begin
        exit(LUXURYCARTAXREFUNDABLETok);
    end;

    procedure NETAMOUNTFORTHISSTATEMENT(): Text[80]
    begin
        exit(NETAMOUNTFORTHISSTATEMENTTok);
    end;

    procedure NONCAPITALPURCHASES(): Text[80]
    begin
        exit(NONCAPITALPURCHASESTok);
    end;

    procedure OTHERGSTFREESUPPLIES(): Text[80]
    begin
        exit(OTHERGSTFREESUPPLIESTok);
    end;

    procedure PAYGINSTALMENT(): Text[80]
    begin
        exit(PAYGINSTALMENTTok);
    end;

    procedure PAYGWITHHOLDING(): Text[80]
    begin
        exit(PAYGWITHHOLDINGTok);
    end;

    procedure PAYGIOPTION1(): Text[80]
    begin
        exit(PAYGIOPTION1Tok);
    end;

    procedure PAYGIOPTION2(): Text[80]
    begin
        exit(PAYGIOPTION2Tok);
    end;

    procedure PAYMENTDUEON(): Text[80]
    begin
        exit(PAYMENTDUEONTok);
    end;

    procedure PERIODDATEFROM(): Text[80]
    begin
        exit(PERIODDATEFROMTok);
    end;

    procedure PERIODDATETO(): Text[80]
    begin
        exit(PERIODDATETOTok);
    end;

    procedure REASONFORFBTVARIATION(): Text[80]
    begin
        exit(REASONFORFBTVARIATIONTok);
    end;

    procedure REASONVARIATION(): Text[80]
    begin
        exit(REASONVARIATIONTok);
    end;

    procedure TOTALCREDITS(): Text[80]
    begin
        exit(TOTALCREDITSTok);
    end;

    procedure TOTALDEBITS(): Text[80]
    begin
        exit(TOTALDEBITSTok);
    end;

    procedure TOTALPAYMENTSWITHHOLDINGAMOUNT(): Text[80]
    begin
        exit(TOTALPAYMENTSWITHHOLDINGAMOUNTTok);
    end;

    procedure TOTALWITHHELDAMOUNT(): Text[80]
    begin
        exit(TOTALWITHHELDAMOUNTTok);
    end;

    procedure VARIEDFBTINSTALMENT(): Text[80]
    begin
        exit(VARIEDFBTINSTALMENTTok);
    end;

    procedure VARIEDGSTINSTALMENT(): Text[80]
    begin
        exit(VARIEDGSTINSTALMENTTok);
    end;

    procedure VARIEDINSTALMENT(): Text[80]
    begin
        exit(VARIEDINSTALMENTTok);
    end;

    procedure VARIEDINSTALMENTRATE(): Text[80]
    begin
        exit(VARIEDINSTALMENTRATETok);
    end;

    procedure WINEEQUALISATIONTAXPAYABLE(): Text[80]
    begin
        exit(WINEEQUALISATIONTAXPAYABLETok);
    end;

    procedure WINEEQUALISATIONTAXREFUNDABLE(): Text[80]
    begin
        exit(WINEEQUALISATIONTAXREFUNDABLETok);
    end;

    procedure WITHHELDFROMINVESTMENTDISTRIBUTIONSAMOUNT(): Text[80]
    begin
        exit(WITHHELDFROMINVESTMENTDISTRIBUTIONSAMOUNTTok);
    end;

    procedure WITHHELDFROMINVOICESNOABN(): Text[80]
    begin
        exit(WITHHELDFROMINVOICESNOABNTok);
    end;

    procedure WITHHELDFROMSALARYAMOUNT(): Text[80]
    begin
        exit(WITHHELDFROMSALARYAMOUNTTok);
    end;

    var
        ABNTok: Label 'ABN', MaxLength = 80, Locked = true;
        ATOCALCULATEDAMOUNTTok: Label 'ATO_CALCULATED_AMOUNT', MaxLength = 80, Locked = true;
        ATOGSTINSTALMENTAMOUNTTok: Label 'ATO_GST_INSTALMENT_AMOUNT', MaxLength = 80, Locked = true;
        CALG12Tok: Label 'CAL_G12', MaxLength = 80, Locked = true;
        CALG13Tok: Label 'CAL_G13', MaxLength = 80, Locked = true;
        CALG14Tok: Label 'CAL_G14', MaxLength = 80, Locked = true;
        CALG15Tok: Label 'CAL_G15', MaxLength = 80, Locked = true;
        CALG16Tok: Label 'CAL_G16', MaxLength = 80, Locked = true;
        CALG17Tok: Label 'CAL_G17', MaxLength = 80, Locked = true;
        CALG18Tok: Label 'CAL_G18', MaxLength = 80, Locked = true;
        CALG19Tok: Label 'CAL_G19', MaxLength = 80, Locked = true;
        CALG20Tok: Label 'CAL_G20', MaxLength = 80, Locked = true;
        CALG4Tok: Label 'CAL_G4', MaxLength = 80, Locked = true;
        CALG5Tok: Label 'CAL_G5', MaxLength = 80, Locked = true;
        CALG6Tok: Label 'CAL_G6', MaxLength = 80, Locked = true;
        CALG7Tok: Label 'CAL_G7', MaxLength = 80, Locked = true;
        CALG8Tok: Label 'CAL_G8', MaxLength = 80, Locked = true;
        CALG9Tok: Label 'CAL_G9', MaxLength = 80, Locked = true;
        CALCULATEDINSTALMENTAMOUNTTok: Label 'CALCULATED_INSTALMENT_AMOUNT', MaxLength = 80, Locked = true;
        CAPITALPURCHASESTok: Label 'CAPITAL_PURCHASES', MaxLength = 80, Locked = true;
        COMMISSIONERSINSTALMENTRATETok: Label 'COMMISSIONERS_INSTALMENT_RATE', MaxLength = 80, Locked = true;
        CREDITFROMREDUCEDFBTINSTALMENTSTok: Label 'CREDIT_FROM_REDUCED_FBT_INSTALMENTS', MaxLength = 80, Locked = true;
        CREDITFROMREDUCEDPAYGINSTALMENTSTok: Label 'CREDIT_FROM_REDUCED_PAYG_INSTALMENTS', MaxLength = 80, Locked = true;
        DINTok: Label 'DIN', MaxLength = 80, Locked = true;
        ESTIMATEDFBTTAXTok: Label 'ESTIMATED_FBT_TAX', MaxLength = 80, Locked = true;
        ESTIMATEDGSTFORYEARTok: Label 'ESTIMATED_GST_FOR_YEAR', MaxLength = 80, Locked = true;
        ESTIMATEDYEARINCOMETAXTok: Label 'ESTIMATED_YEAR_INCOME_TAX', MaxLength = 80, Locked = true;
        EXPORTSTok: Label 'EXPORTS', MaxLength = 80, Locked = true;
        FBTINSTALMENTTok: Label 'FBT_INSTALMENT', MaxLength = 80, Locked = true;
        FORMDUEONTok: Label 'FORM_DUE_ON', MaxLength = 80, Locked = true;
        GSTINSTALMENTSTok: Label 'GST_INSTALMENTS', MaxLength = 80, Locked = true;
        GSTREASONFORVARIATIONTok: Label 'GST_REASON_FOR_VARIATION', MaxLength = 80, Locked = true;
        GSTREFUNDTok: Label 'GST_REFUND', MaxLength = 80, Locked = true;
        GSTTAXTok: Label 'GST_TAX', MaxLength = 80, Locked = true;
        GSTTOTALSALESTok: Label 'GST_TOTAL_SALES', MaxLength = 80, Locked = true;
        INSTALMENTINCOMETok: Label 'INSTALMENT_INCOME', MaxLength = 80, Locked = true;
        LUXURYCARTAXPAYABLETok: Label 'LUXURY_CAR_TAX_PAYABLE', MaxLength = 80, Locked = true;
        LUXURYCARTAXREFUNDABLETok: Label 'LUXURY_CAR_TAX_REFUNDABLE', MaxLength = 80, Locked = true;
        NETAMOUNTFORTHISSTATEMENTTok: Label 'NET_AMOUNT_FOR_THIS_STATEMENT', MaxLength = 80, Locked = true;
        NONCAPITALPURCHASESTok: Label 'NON_CAPITAL_PURCHASES', MaxLength = 80, Locked = true;
        OTHERGSTFREESUPPLIESTok: Label 'OTHER_GST_FREE_SUPPLIES', MaxLength = 80, Locked = true;
        PAYGINSTALMENTTok: Label 'PAYG_INSTALMENT', MaxLength = 80, Locked = true;
        PAYGWITHHOLDINGTok: Label 'PAYG_WITHHOLDING', MaxLength = 80, Locked = true;
        PAYGIOPTION1Tok: Label 'PAYGI_OPTION_1', MaxLength = 80, Locked = true;
        PAYGIOPTION2Tok: Label 'PAYGI_OPTION_2', MaxLength = 80, Locked = true;
        PAYMENTDUEONTok: Label 'PAYMENT_DUE_ON', MaxLength = 80, Locked = true;
        PERIODDATEFROMTok: Label 'PERIOD_DATE_FROM', MaxLength = 80, Locked = true;
        PERIODDATETOTok: Label 'PERIOD_DATE_TO', MaxLength = 80, Locked = true;
        REASONFORFBTVARIATIONTok: Label 'REASON_FOR_FBT_VARIATION', MaxLength = 80, Locked = true;
        REASONVARIATIONTok: Label 'REASON_VARIATION', MaxLength = 80, Locked = true;
        TOTALCREDITSTok: Label 'TOTAL_CREDITS', MaxLength = 80, Locked = true;
        TOTALDEBITSTok: Label 'TOTAL_DEBITS', MaxLength = 80, Locked = true;
        TOTALPAYMENTSWITHHOLDINGAMOUNTTok: Label 'TOTAL_PAYMENTS_WITHHOLDING_AMOUNT', MaxLength = 80, Locked = true;
        TOTALWITHHELDAMOUNTTok: Label 'TOTAL_WITHHELD_AMOUNT', MaxLength = 80, Locked = true;
        VARIEDFBTINSTALMENTTok: Label 'VARIED_FBT_INSTALMENT', MaxLength = 80, Locked = true;
        VARIEDGSTINSTALMENTTok: Label 'VARIED_GST_INSTALMENT', MaxLength = 80, Locked = true;
        VARIEDINSTALMENTTok: Label 'VARIED_INSTALMENT', MaxLength = 80, Locked = true;
        VARIEDINSTALMENTRATETok: Label 'VARIED_INSTALMENT_RATE', MaxLength = 80, Locked = true;
        WINEEQUALISATIONTAXPAYABLETok: Label 'WINE_EQUALISATION_TAX_PAYABLE', MaxLength = 80, Locked = true;
        WINEEQUALISATIONTAXREFUNDABLETok: Label 'WINE_EQUALISATION_TAX_REFUNDABLE', MaxLength = 80, Locked = true;
        WITHHELDFROMINVESTMENTDISTRIBUTIONSAMOUNTTok: Label 'WITHHELD_FROM_INVESTMENT_DISTRIBUTIONS_AMOUNT', MaxLength = 80, Locked = true;
        WITHHELDFROMINVOICESNOABNTok: Label 'WITHHELD_FROM_INVOICES_NO_ABN', MaxLength = 80, Locked = true;
        WITHHELDFROMSALARYAMOUNTTok: Label 'WITHHELD_FROM_SALARY_AMOUNT', MaxLength = 80, Locked = true;

}