// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using System.Environment;

xmlport 31110 "VAT Control Report DPHKH1 CZL"
{
    Caption = 'VAT Control Report';
    Direction = Export;
    Encoding = UTF8;
    Format = Xml;
    FormatEvaluate = Xml;

    schema
    {
        textelement(Pisemnost)
        {
            textattribute(swversion)
            {
                Occurrence = Optional;
                XmlName = 'verzeSW';
            }
            textattribute(swname)
            {
                Occurrence = Optional;
                XmlName = 'nazevSW';
            }
            tableelement(VATCtrlReportHeaderCZL; "VAT Ctrl. Report Header CZL")
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'DPHKH1';

                textelement(VetaD)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    textattribute(vatyear)
                    {
                        Occurrence = Required;
                        XmlName = 'rok';
                    }
                    textattribute(formtype)
                    {
                        XmlName = 'khdph_forma';
                    }
                    textattribute(documentformat)
                    {
                        Occurrence = Required;
                        XmlName = 'dokument';

                        trigger OnBeforePassVariable()
                        begin
                            documentformat := 'KH1';
                        end;
                    }
                    textattribute(reasonsobservedon)
                    {
                        Occurrence = Optional;
                        XmlName = 'd_zjist';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(ReasonsObservedOn);
                        end;
                    }
                    textattribute(vyzva_odp)
                    {
                        Occurrence = Optional;
                        XmlName = 'vyzva_odp';
                    }
                    textattribute(vatquarter)
                    {
                        Occurrence = Optional;
                        XmlName = 'ctvrt';
                    }
                    textattribute(vatmonth)
                    {
                        Occurrence = Optional;
                        XmlName = 'mesic';
                    }
                    textattribute(todaydate)
                    {
                        Occurrence = Optional;
                        XmlName = 'd_poddp';
                    }
                    textattribute(vattaskabbreviation)
                    {
                        Occurrence = Required;
                        XmlName = 'k_uladis';

                        trigger OnBeforePassVariable()
                        begin
                            vattaskabbreviation := 'DPH';
                        end;
                    }
                    textattribute(c_jed_vyzvy)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_jed_vyzvy';
                    }
                }
                textelement(VetaP)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    textattribute(fillempphoneno)
                    {
                        Occurrence = Optional;
                        XmlName = 'sest_telef';
                    }
                    textattribute(houseno)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_pop';
                    }
                    textattribute(natperstitle)
                    {
                        Occurrence = Optional;
                        XmlName = 'titul';
                    }
                    textattribute(compemail)
                    {
                        XmlName = 'email';
                    }
                    textattribute(postcode)
                    {
                        Occurrence = Optional;
                        XmlName = 'psc';
                    }
                    textattribute(zast_ic)
                    {
                        Occurrence = Optional;
                        XmlName = 'zast_ic';
                    }
                    textattribute(taxpayertype)
                    {
                        Occurrence = Required;
                        XmlName = 'typ_ds';
                    }
                    textattribute(zast_nazev)
                    {
                        Occurrence = Optional;
                        XmlName = 'zast_nazev';
                    }
                    textattribute(compphoneno)
                    {
                        XmlName = 'c_telef';
                    }
                    textattribute(zast_jmeno)
                    {
                        Occurrence = Optional;
                        XmlName = 'zast_jmeno';
                    }
                    textattribute(zast_prijmeni)
                    {
                        XmlName = 'zast_prijmeni';
                    }
                    textattribute(city)
                    {
                        Occurrence = Optional;
                        XmlName = 'naz_obce';
                    }
                    textattribute(zast_typ)
                    {
                        Occurrence = Optional;
                        XmlName = 'zast_typ';
                    }
                    textattribute(c_ufo)
                    {
                        Occurrence = Required;
                        XmlName = 'c_ufo';
                    }
                    textattribute(companytradename)
                    {
                        Occurrence = Optional;
                        XmlName = 'zkrobchjm';
                    }
                    textattribute(c_pracufo)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_pracufo';
                    }
                    textattribute(compregion)
                    {
                        Occurrence = Optional;
                        XmlName = 'stat';
                    }
                    textattribute(authempjobtitle)
                    {
                        Occurrence = Optional;
                        XmlName = 'opr_postaveni';
                    }
                    textattribute(zast_dat_nar)
                    {
                        Occurrence = Optional;
                        XmlName = 'zast_dat_nar';
                    }
                    textattribute(natpersfirstname)
                    {
                        Occurrence = Optional;
                        XmlName = 'jmeno';
                    }
                    textattribute(fillemplastname)
                    {
                        Occurrence = Optional;
                        XmlName = 'sest_prijmeni';
                    }
                    textattribute(zast_ev_cislo)
                    {
                        Occurrence = Optional;
                        XmlName = 'zast_ev_cislo';
                    }
                    textattribute(municipalityno)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_orient';
                    }
                    textattribute(authemplastname)
                    {
                        Occurrence = Optional;
                        XmlName = 'opr_prijmeni';
                    }
                    textattribute(fillempfirstname)
                    {
                        Occurrence = Optional;
                        XmlName = 'sest_jmeno';
                    }
                    textattribute(natperslastname)
                    {
                        Occurrence = Optional;
                        XmlName = 'prijmeni';
                    }
                    textattribute(street)
                    {
                        Occurrence = Optional;
                        XmlName = 'ulice';
                    }
                    textattribute(zast_kod)
                    {
                        Occurrence = Optional;
                        XmlName = 'zast_kod';
                    }
                    textattribute(vatregno)
                    {
                        Occurrence = Required;
                        XmlName = 'dic';
                    }
                    textattribute(authempfirstname)
                    {
                        Occurrence = Optional;
                        XmlName = 'opr_jmeno';
                    }
                    textattribute(id_dats)
                    {
                        Occurrence = Optional;
                        XmlName = 'id_dats';
                    }
                }
                tableelement(a1; "VAT Ctrl. Report Buffer CZL")
                {
                    MinOccurs = Zero;
                    XmlName = 'VetaA1';
                    UseTemporary = true;
                    textattribute(a1_c_evid_dd)
                    {
                        Occurrence = Required;
                        XmlName = 'c_evid_dd';
                    }
                    textattribute(a1_zakl_dane1)
                    {
                        Occurrence = Required;
                        XmlName = 'zakl_dane1';
                    }
                    textattribute(a1_c_radku)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_radku';
                    }
                    textattribute(a1_duzp)
                    {
                        Occurrence = Required;
                        XmlName = 'duzp';
                    }
                    textattribute(a1_dic_odb)
                    {
                        Occurrence = Required;
                        XmlName = 'dic_odb';
                    }
                    textattribute(a1_kod_pred_pl)
                    {
                        Occurrence = Required;
                        XmlName = 'kod_pred_pl';
                    }
                    trigger OnAfterGetRecord()
                    begin
                        A1_c_evid_dd := A1."Document No.";
                        A1_zakl_dane1 := FormatDec(A1."Base 1" + A1."Base 2" + A1."Base 3");
                        A1_c_radku := FormatInt(A1."Line No.");
                        A1_duzp := FormatDate(A1."VAT Date");
                        A1_dic_odb := FormatVATRegistration(A1."VAT Registration No.");
                        A1_kod_pred_pl := LowerCase(A1."Commodity Code");

                        if A1."Original Document VAT Date" <> 0D then
                            A1_duzp := FormatDate(A1."Original Document VAT Date");
                    end;

                    trigger OnPreXmlItem()
                    begin
                        CopyBufferToSection(A1, 'A1');
                    end;
                }
                tableelement(a2; "VAT Ctrl. Report Buffer CZL")
                {
                    MinOccurs = Zero;
                    XmlName = 'VetaA2';
                    UseTemporary = true;
                    textattribute(a2_c_evid_dd)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_evid_dd';
                    }
                    textattribute(a2_dan1)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan1';
                    }
                    textattribute(a2_c_radku)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_radku';
                    }
                    textattribute(a2_dppd)
                    {
                        Occurrence = Required;
                        XmlName = 'dppd';
                    }
                    textattribute(a2_zakl_dane2)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane2';
                    }
                    textattribute(a2_dan2)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan2';
                    }
                    textattribute(a2_dan3)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan3';
                    }
                    textattribute(a2_vatid_dod)
                    {
                        Occurrence = Optional;
                        XmlName = 'vatid_dod';
                    }
                    textattribute(a2_zakl_dane1)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane1';
                    }
                    textattribute(a2_zakl_dane3)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane3';
                    }
                    textattribute(a2_k_stat)
                    {
                        Occurrence = Optional;
                        XmlName = 'k_stat';
                    }
                    trigger OnAfterGetRecord()
                    begin
                        A2_c_evid_dd := A2."Document No.";
                        A2_dan1 := FormatDec(A2."Amount 1");
                        A2_c_radku := FormatInt(A2."Line No.");
                        A2_dppd := FormatDate(A2."VAT Date");
                        A2_zakl_dane2 := FormatDec(A2."Base 2");
                        A2_dan2 := FormatDec(A2."Amount 2");
                        A2_dan3 := FormatDec(A2."Amount 3");
                        A2_vatid_dod := FormatVATRegistration(A2."VAT Registration No.");
                        A2_zakl_dane1 := FormatDec(A2."Base 1");
                        A2_zakl_dane3 := FormatDec(A2."Base 3");
                        A2_k_stat := GetCountryCodeFromVATRegistrationNo(A2."VAT Registration No.");

                        if A2."Original Document VAT Date" <> 0D then
                            A2_dppd := FormatDate(A2."Original Document VAT Date");
                    end;

                    trigger OnPreXmlItem()
                    begin
                        CopyBufferToSection(A2, 'A2');
                    end;
                }
                tableelement(a3; "VAT Ctrl. Report Buffer CZL")
                {
                    MinOccurs = Zero;
                    XmlName = 'VetaA3';
                    UseTemporary = true;
                    textattribute(a3_jm_prijm_obch)
                    {
                        Occurrence = Optional;
                        XmlName = 'jm_prijm_obch';
                    }
                    textattribute(a3_m_pobytu_sidlo)
                    {
                        Occurrence = Optional;
                        XmlName = 'm_pobytu_sidlo';
                    }
                    textattribute(a3_c_evid_dd)
                    {
                        Occurrence = Required;
                        XmlName = 'c_evid_dd';
                    }
                    textattribute(a3_k_stat)
                    {
                        Occurrence = Optional;
                        XmlName = 'k_stat';
                    }
                    textattribute(a3_c_radku)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_radku';
                    }
                    textattribute(a3_vatid_odb)
                    {
                        Occurrence = Optional;
                        XmlName = 'vatid_odb';
                    }
                    textattribute(a3_osv_plneni)
                    {
                        Occurrence = Required;
                        XmlName = 'osv_plneni';
                    }
                    textattribute(a3_d_narozeni)
                    {
                        Occurrence = Optional;
                        XmlName = 'd_narozeni';
                    }
                    textattribute(a3_dup)
                    {
                        Occurrence = Required;
                        XmlName = 'dup';
                    }
                    trigger OnAfterGetRecord()
                    begin
                        A3_jm_prijm_obch := A3.Name;
                        A3_m_pobytu_sidlo := A3."Place of Stay";
                        A3_c_evid_dd := A3."Document No.";
                        A3_c_radku := FormatInt(A3."Line No.");
                        A3_vatid_odb := FormatVATRegistration(A3."VAT Registration No.");
                        A3_osv_plneni := FormatDec(A3."Base 1" + A3."Amount 1");
                        A3_d_narozeni := FormatDate(A3."Birth Date");
                        A3_dup := FormatDate(A3."VAT Date");
                        A3_k_stat := GetCountryCodeFromVATRegistrationNo(A3."VAT Registration No.");

                        if A3."Original Document VAT Date" <> 0D then
                            A3_dup := FormatDate(A3."Original Document VAT Date");
                    end;

                    trigger OnPreXmlItem()
                    begin
                        CopyBufferToSection(A3, 'A3');
                    end;
                }
                tableelement(a4; "VAT Ctrl. Report Buffer CZL")
                {
                    MinOccurs = Zero;
                    XmlName = 'VetaA4';
                    UseTemporary = true;
                    textattribute(a4_c_evid_dd)
                    {
                        Occurrence = Required;
                        XmlName = 'c_evid_dd';
                    }
                    textattribute(a4_zakl_dane1)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane1';
                    }
                    textattribute(a4_zakl_dane2)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane2';
                    }
                    textattribute(a4_dan1)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan1';
                    }
                    textattribute(a4_dic_odb)
                    {
                        Occurrence = Required;
                        XmlName = 'dic_odb';
                    }
                    textattribute(a4_dppd)
                    {
                        Occurrence = Required;
                        XmlName = 'dppd';
                    }
                    textattribute(a4_dan2)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan2';
                    }
                    textattribute(a4_kod_rezim_pl)
                    {
                        Occurrence = Required;
                        XmlName = 'kod_rezim_pl';
                    }
                    textattribute(a4_zdph_44)
                    {
                        Occurrence = Required;
                        XmlName = 'zdph_44';
                    }
                    textattribute(a4_c_radku)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_radku';
                    }
                    textattribute(a4_zakl_dane3)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane3';
                    }
                    textattribute(a4_dan3)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan3';
                    }
                    trigger OnAfterGetRecord()
                    begin
                        A4_c_evid_dd := A4."Document No.";
                        A4_zakl_dane1 := FormatDec(A4."Base 1");
                        A4_zakl_dane2 := FormatDec(A4."Base 2");
                        A4_dan1 := FormatDec(A4."Amount 1");
                        A4_dic_odb := FormatVATRegistration(A4."VAT Registration No.");
                        A4_dppd := FormatDate(A4."VAT Date");
                        A4_dan2 := FormatDec(A4."Amount 2");
                        A4_kod_rezim_pl := Format(A4."Supplies Mode Code");
                        A4_zdph_44 := ConvertCorrectionsForBadReceivable(A4."Corrections for Bad Receivable");
                        A4_c_radku := FormatInt(A4."Line No.");
                        A4_zakl_dane3 := FormatDec(A4."Base 3");
                        A4_dan3 := FormatDec(A4."Amount 3");

                        if A4."Original Document VAT Date" <> 0D then
                            A4_dppd := FormatDate(A4."Original Document VAT Date");
                    end;

                    trigger OnPreXmlItem()
                    begin
                        CopyBufferToSection(A4, 'A4');
                    end;
                }
                tableelement(a5; "VAT Ctrl. Report Buffer CZL")
                {
                    MinOccurs = Zero;
                    XmlName = 'VetaA5';
                    UseTemporary = true;
                    textattribute(a5_zakl_dane2)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane2';
                    }
                    textattribute(a5_dan2)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan2';
                    }
                    textattribute(a5_dan3)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan3';
                    }
                    textattribute(a5_dan1)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan1';
                    }
                    textattribute(a5_zakl_dane3)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane3';
                    }
                    textattribute(a5_zakl_dane1)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane1';
                    }
                    trigger OnAfterGetRecord()
                    begin
                        A5_dan1 := FormatDec(A5."Amount 1");
                        A5_dan2 := FormatDec(A5."Amount 2");
                        A5_dan3 := FormatDec(A5."Amount 3");
                        A5_zakl_dane1 := FormatDec(A5."Base 1");
                        A5_zakl_dane2 := FormatDec(A5."Base 2");
                        A5_zakl_dane3 := FormatDec(A5."Base 3");
                    end;

                    trigger OnPreXmlItem()
                    begin
                        CopyBufferToSection(A5, 'A5');
                    end;
                }
                tableelement(b1; "VAT Ctrl. Report Buffer CZL")
                {
                    MinOccurs = Zero;
                    XmlName = 'VetaB1';
                    UseTemporary = true;
                    textattribute(b1_zakl_dane2)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane2';
                    }
                    textattribute(b1_zakl_dane3)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane3';
                    }
                    textattribute(b1_dan3)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan3';
                    }
                    textattribute(b1_duzp)
                    {
                        Occurrence = Required;
                        XmlName = 'duzp';
                    }
                    textattribute(b1_dan2)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan2';
                    }
                    textattribute(b1_c_radku)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_radku';
                    }
                    textattribute(b1_dan1)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan1';
                    }
                    textattribute(b1_kod_pred_pl)
                    {
                        Occurrence = Required;
                        XmlName = 'kod_pred_pl';
                    }
                    textattribute(b1_dic_dod)
                    {
                        Occurrence = Required;
                        XmlName = 'dic_dod';
                    }
                    textattribute(b1_zakl_dane1)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane1';
                    }
                    textattribute(b1_c_evid_dd)
                    {
                        Occurrence = Required;
                        XmlName = 'c_evid_dd';
                    }
                    trigger OnAfterGetRecord()
                    begin
                        B1_zakl_dane2 := FormatDec(B1."Base 2");
                        B1_zakl_dane3 := FormatDec(B1."Base 3");
                        B1_dan3 := FormatDec(B1."Amount 3");
                        B1_duzp := FormatDate(B1."VAT Date");
                        B1_dan2 := FormatDec(B1."Amount 2");
                        B1_c_radku := FormatInt(B1."Line No.");
                        B1_dan1 := FormatDec(B1."Amount 1");
                        B1_kod_pred_pl := LowerCase(B1."Commodity Code");
                        B1_dic_dod := FormatVATRegistration(B1."VAT Registration No.");
                        B1_zakl_dane1 := FormatDec(B1."Base 1");
                        B1_c_evid_dd := B1."Document No.";

                        if B1."Original Document VAT Date" <> 0D then
                            B1_duzp := FormatDate(B1."Original Document VAT Date");
                    end;

                    trigger OnPreXmlItem()
                    begin
                        CopyBufferToSection(B1, 'B1');
                    end;
                }
                tableelement(b2; "VAT Ctrl. Report Buffer CZL")
                {
                    MinOccurs = Zero;
                    XmlName = 'VetaB2';
                    UseTemporary = true;
                    textattribute(b2_zakl_dane3)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane3';
                    }
                    textattribute(b2_pomer)
                    {
                        Occurrence = Required;
                        XmlName = 'pomer';
                    }
                    textattribute(b2_dppd)
                    {
                        Occurrence = Required;
                        XmlName = 'dppd';
                    }
                    textattribute(b2_c_radku)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_radku';
                    }
                    textattribute(b2_dan2)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan2';
                    }
                    textattribute(b2_zakl_dane1)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane1';
                    }
                    textattribute(b2_zdph_44)
                    {
                        Occurrence = Required;
                        XmlName = 'zdph_44';
                    }
                    textattribute(b2_dic_dod)
                    {
                        Occurrence = Required;
                        XmlName = 'dic_dod';
                    }
                    textattribute(b2_zakl_dane2)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane2';
                    }
                    textattribute(b2_dan1)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan1';
                    }
                    textattribute(b2_c_evid_dd)
                    {
                        Occurrence = Required;
                        XmlName = 'c_evid_dd';
                    }
                    textattribute(b2_dan3)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan3';
                    }
                    trigger OnAfterGetRecord()
                    begin
                        B2_zakl_dane3 := FormatDec(B2."Base 3");
                        B2_pomer := VATStmtXMLExportHelperCZL.ConvertBoolean(B2."Ratio Use");
                        B2_dppd := FormatDate(B2."VAT Date");
                        B2_c_radku := FormatInt(B2."Line No.");
                        B2_dan2 := FormatDec(B2."Amount 2");
                        B2_zakl_dane1 := FormatDec(B2."Base 1");
                        B2_zdph_44 := ConvertCorrectionsForBadReceivable(B2."Corrections for Bad Receivable");
                        B2_dic_dod := FormatVATRegistration(B2."VAT Registration No.");
                        B2_zakl_dane2 := FormatDec(B2."Base 2");
                        B2_dan1 := FormatDec(B2."Amount 1");
                        B2_c_evid_dd := B2."Document No.";
                        B2_dan3 := FormatDec(B2."Amount 3");

                        if B2."Original Document VAT Date" <> 0D then
                            B2_dppd := FormatDate(B2."Original Document VAT Date");
                    end;

                    trigger OnPreXmlItem()
                    begin
                        CopyBufferToSection(B2, 'B2');
                    end;
                }
                tableelement(b3; "VAT Ctrl. Report Buffer CZL")
                {
                    MinOccurs = Zero;
                    XmlName = 'VetaB3';
                    UseTemporary = true;
                    textattribute(b3_zakl_dane2)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane2';
                    }
                    textattribute(b3_dan3)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan3';
                    }
                    textattribute(b3_zakl_dane3)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane3';
                    }
                    textattribute(b3_dan2)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan2';
                    }
                    textattribute(b3_dan1)
                    {
                        Occurrence = Optional;
                        XmlName = 'dan1';
                    }
                    textattribute(b3_zakl_dane1)
                    {
                        Occurrence = Optional;
                        XmlName = 'zakl_dane1';
                    }
                    trigger OnAfterGetRecord()
                    begin
                        B3_dan1 := FormatDec(B3."Amount 1");
                        B3_dan2 := FormatDec(B3."Amount 2");
                        B3_dan3 := FormatDec(B3."Amount 3");
                        B3_zakl_dane1 := FormatDec(B3."Base 1");
                        B3_zakl_dane2 := FormatDec(B3."Base 2");
                        B3_zakl_dane3 := FormatDec(B3."Base 3");
                    end;

                    trigger OnPreXmlItem()
                    begin
                        CopyBufferToSection(B3, 'B3');
                    end;
                }
                textelement(VetaC)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(celk_zd_a2)
                    {
                        Occurrence = Optional;
                        XmlName = 'celk_zd_a2';
                    }
                    textattribute(obrat23)
                    {
                        Occurrence = Optional;
                        XmlName = 'obrat23';
                    }
                    textattribute(obrat5)
                    {
                        Occurrence = Optional;
                        XmlName = 'obrat5';
                    }
                    textattribute(pln23)
                    {
                        Occurrence = Optional;
                        XmlName = 'pln23';
                    }
                    textattribute(pln5)
                    {
                        Occurrence = Optional;
                        XmlName = 'pln5';
                    }
                    textattribute(pln_rez_pren)
                    {
                        Occurrence = Optional;
                        XmlName = 'pln_rez_pren';
                    }
                    textattribute(rez_pren23)
                    {
                        Occurrence = Optional;
                        XmlName = 'rez_pren23';
                    }
                    textattribute(rez_pren5)
                    {
                        Occurrence = Optional;
                        XmlName = 'rez_pren5';
                    }
                    trigger OnBeforePassVariable()
                    begin
                        if PrintOnlyHeader then
                            currXMLport.Skip();

                        CalcTotalAmounts();
                    end;
                }

                trigger OnPreXmlItem()
                begin
                    VATCtrlReportHeaderCZL.SetRange("No.", VATControlReportNo);
                    VATCtrlReportHeaderCZL.FindFirst();
                end;

                trigger OnAfterGetRecord()
                var
                    VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";
                begin
                    vatmonth := '';
                    vatquarter := '';
                    vatyear := '';
                    case VATCtrlReportHeaderCZL."Report Period" of
                        VATCtrlReportHeaderCZL."Report Period"::Month:
                            vatmonth := Format(VATCtrlReportHeaderCZL."Period No.");
                        VATCtrlReportHeaderCZL."Report Period"::Quarter:
                            vatquarter := Format(VATCtrlReportHeaderCZL."Period No.");
                    end;
                    if VATCtrlReportHeaderCZL.Year <> 0 then
                        vatyear := Format(VATCtrlReportHeaderCZL.Year);
                    VATCtrlReportFormatCZL := VATCtrlReportHeaderCZL."VAT Control Report XML Format";

                    VATCtrlReportMgtCZL.CreateBufferForExport(VATCtrlReportHeaderCZL, TempVATCtrlReportBufferCZL, false, VATStatementReportSelection);
                    TempVATCtrlReportBufferCZL.Reset();
                    if PrintInIntegers then
                        VATCtrlReportMgtCZL.RoundVATCtrlReportBufferAmounts(TempVATCtrlReportBufferCZL, 1);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        LoadXMLParams();
        PrepareExportData();
    end;

    var
        TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary;
        VATStmtXMLExportHelperCZL: Codeunit "VAT Stmt XML Export Helper CZL";
        LengthMustBeErr: Label '%1 length must not be greater than %2.', Comment = '%1 = Field; %2 = Field Length';
        PrintOnlyHeader: Boolean;
        VATCtrlReportFormatCZL: Enum "VAT Ctrl. Report Format CZL";
        SWNameTxt: Label 'Microsoft Dynamics 365 Business Central', Locked = true;
        XmlParams: Text;
        VATControlReportNo: Code[20];
        VATStatementReportSelection: Enum "VAT Statement Report Selection";
        PrintInIntegers: Boolean;
        DeclarationType: Enum "VAT Ctrl. Report Decl Type CZL";
        FilledByEmployeeNo: Code[20];
        ReasonsObservedOnDate: Date;
        FastAppelReaction: Option " ",B,P;
        AppelDocumentNo: Text;


    procedure SetXMLParams(NewXMLParams: Text)
    begin
        XmlParams := NewXMLParams;
    end;

    local procedure LoadXMLParams()
    var
        ParamsXmlDoc: XmlDocument;
    begin
        VATStmtXMLExportHelperCZL.GetParametersXmlDoc(XmlParams, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetVATCtrlReportNo(VATControlReportNo, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetSelection(VATStatementReportSelection, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetRounding(PrintInIntegers, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetDeclarationAndFilledBy(DeclarationType, FilledByEmployeeNo, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetVATControlReportAddParams(ReasonsObservedOnDate, FastAppelReaction, AppelDocumentNo, ParamsXmlDoc);
    end;

    local procedure PrepareExportData()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        CompanyInformation: Record "Company Information";
        CompanyOfficialCZL: Record "Company Official CZL";
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        StatutoryReportingSetupCZL.Get();
        CompanyInformation.Get();

        SWVersion := ApplicationSystemConstants.ApplicationVersion();
        SWName := SWNameTxt;

        // 'D'
        FormType := ConvertDeclarationType(DeclarationType);
        if ReasonsObservedOnDate <> 0D then
            ReasonsObservedOn := FormatDate(ReasonsObservedOnDate);
        TodayDate := FormatDate(Today);
        vyzva_odp := FormatFastAppelReaction(FastAppelReaction);
        c_jed_vyzvy := AppelDocumentNo;

        PrintOnlyHeader := FastAppelReaction <> FastAppelReaction::" ";

        // 'P'
        CheckLen(StatutoryReportingSetupCZL."Tax Office Number", StatutoryReportingSetupCZL.FieldCaption("Tax Office Number"), 3);
        c_ufo := StatutoryReportingSetupCZL."Tax Office Number";
        c_pracufo := StatutoryReportingSetupCZL."Tax Office Region Number";
        VATRegNo := FormatVATRegistration(CompanyInformation."VAT Registration No.");
        StatutoryReportingSetupCZL.TestField("Company Type");
        TaxPayerType := VATStmtXMLExportHelperCZL.ConvertSubjectType(StatutoryReportingSetupCZL."Company Type");

        CheckLen(StatutoryReportingSetupCZL."Individual First Name", StatutoryReportingSetupCZL.FieldCaption("Individual First Name"), 20);
        NatPersFirstName := StatutoryReportingSetupCZL."Individual First Name";
        NatPersLastName := StatutoryReportingSetupCZL."Individual Surname";
        CheckLen(StatutoryReportingSetupCZL."Individual Title", StatutoryReportingSetupCZL.FieldCaption("Individual Title"), 10);
        NatPersTitle := StatutoryReportingSetupCZL."Individual Title";
        CompanyTradeName := StatutoryReportingSetupCZL."Company Trade Name";
        City := StatutoryReportingSetupCZL.City;
        CheckLen(StatutoryReportingSetupCZL.Street, StatutoryReportingSetupCZL.FieldCaption(Street), 38);
        Street := StatutoryReportingSetupCZL.Street;
        CheckLen(StatutoryReportingSetupCZL."House No.", StatutoryReportingSetupCZL.FieldCaption("House No."), 6);
        HouseNo := StatutoryReportingSetupCZL."House No.";
        CheckLen(StatutoryReportingSetupCZL."Municipality No.", StatutoryReportingSetupCZL.FieldCaption("Municipality No."), 4);
        MunicipalityNo := StatutoryReportingSetupCZL."Municipality No.";
        PostCode := DelChr(CompanyInformation."Post Code", '=', ' ');
        CheckLen(PostCode, CompanyInformation.FieldCaption("Post Code"), 5);
        if CompanyOfficialCZL.Get(StatutoryReportingSetupCZL."VAT Stat. Auth. Employee No.") then begin
            AuthEmpLastName := CompanyOfficialCZL."Last Name";
            CheckLen(CompanyOfficialCZL."First Name", CompanyOfficialCZL.FieldCaption("First Name"), 20);
            AuthEmpFirstName := CompanyOfficialCZL."First Name";
            AuthEmpJobTitle := CompanyOfficialCZL."Job Title";
        end;
        if CompanyOfficialCZL.Get(FilledByEmployeeNo) then begin
            FillEmpLastName := CompanyOfficialCZL."Last Name";
            CheckLen(CompanyOfficialCZL."First Name", CompanyOfficialCZL.FieldCaption("First Name"), 20);
            FillEmpFirstName := CompanyOfficialCZL."First Name";
            CheckLen(CompanyOfficialCZL."Phone No.", CompanyOfficialCZL.FieldCaption("Phone No."), 14);
            FillEmpPhoneNo := CompanyOfficialCZL."Phone No.";
        end;

        CheckLen(CompanyInformation."Phone No.", CompanyInformation.FieldCaption("Phone No."), 14);
        CompPhoneNo := CompanyInformation."Phone No.";
        CompRegion := StatutoryReportingSetupCZL."VAT Statement Country Name";
        id_dats := StatutoryReportingSetupCZL."Data Box ID";
        CompEmail := StatutoryReportingSetupCZL."VAT Control Report E-mail";

        zast_kod := StatutoryReportingSetupCZL."Official Code";
        zast_typ := VATStmtXMLExportHelperCZL.ConvertSubjectType(StatutoryReportingSetupCZL."Official Type");
        zast_nazev := StatutoryReportingSetupCZL."Official Name";
        zast_jmeno := StatutoryReportingSetupCZL."Official First Name";
        zast_prijmeni := StatutoryReportingSetupCZL."Official Surname";
        zast_dat_nar := FormatDate(StatutoryReportingSetupCZL."Official Birth Date");
        zast_ev_cislo := StatutoryReportingSetupCZL."Official Reg.No.of Tax Adviser";
        zast_ic := StatutoryReportingSetupCZL."Official Registration No.";
    end;

    procedure CopyBuffer(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
        if PrintOnlyHeader then
            exit;

        if TempVATCtrlReportBufferCZL.FindSet() then
            repeat
                TempVATCtrlReportBufferCZL := TempVATCtrlReportBufferCZL;
                TempVATCtrlReportBufferCZL.Insert();
            until TempVATCtrlReportBufferCZL.Next() = 0;
    end;

    local procedure CopyBufferToSection(var SectionTempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; SectionCode: Code[20])
    begin
        SectionTempVATCtrlReportBufferCZL.Reset();
        SectionTempVATCtrlReportBufferCZL.DeleteAll();

        TempVATCtrlReportBufferCZL.Reset();
        TempVATCtrlReportBufferCZL.SetRange("VAT Ctrl. Report Section Code", SectionCode);
        if TempVATCtrlReportBufferCZL.FindSet() then
            repeat
                if ((TempVATCtrlReportBufferCZL."Base 1" + TempVATCtrlReportBufferCZL."Amount 1") <> 0) or
                   ((TempVATCtrlReportBufferCZL."Base 2" + TempVATCtrlReportBufferCZL."Amount 2") <> 0) or
                   ((TempVATCtrlReportBufferCZL."Base 3" + TempVATCtrlReportBufferCZL."Amount 3") <> 0)
                then begin
                    SectionTempVATCtrlReportBufferCZL := TempVATCtrlReportBufferCZL;
                    if SectionTempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code" in ['A1', 'A3', 'A4', 'A5'] then begin
                        SectionTempVATCtrlReportBufferCZL."Base 1" *= -1;
                        SectionTempVATCtrlReportBufferCZL."Amount 1" *= -1;
                        SectionTempVATCtrlReportBufferCZL."Base 2" *= -1;
                        SectionTempVATCtrlReportBufferCZL."Amount 2" *= -1;
                        SectionTempVATCtrlReportBufferCZL."Base 3" *= -1;
                        SectionTempVATCtrlReportBufferCZL."Amount 3" *= -1;
                        SectionTempVATCtrlReportBufferCZL."Total Base" *= -1;
                        SectionTempVATCtrlReportBufferCZL."Total Amount" *= -1;
                    end;
                    SectionTempVATCtrlReportBufferCZL.Insert();
                end;
            until TempVATCtrlReportBufferCZL.Next() = 0;
    end;

    procedure CheckLen(FieldNam: Text; FieldCapt: Text; MaxLen: Integer)
    begin
        if StrLen(FieldNam) > MaxLen then
            Error(LengthMustBeErr, FieldCapt, MaxLen);
    end;

    local procedure CalcTotalAmounts()
    begin
        CalcTotalAmountsBuffer(A1);
        CalcTotalAmountsBuffer(A2);
        CalcTotalAmountsBuffer(A4);
        CalcTotalAmountsBuffer(A5);
        CalcTotalAmountsBuffer(B1);
        CalcTotalAmountsBuffer(B2);
        CalcTotalAmountsBuffer(B3);

        celk_zd_a2 := FormatDec(A2."Base 1" + A2."Base 2" + A2."Base 3");
        obrat23 := FormatDec(A4."Base 1" + A5."Base 1");
        obrat5 := FormatDec(A4."Base 2" + A4."Base 3" + A5."Base 2" + A5."Base 3");
        pln23 := FormatDec(B2."Base 1" + B3."Base 1");
        pln5 := FormatDec(B2."Base 2" + B2."Base 3" + B3."Base 2" + B3."Base 3");
        pln_rez_pren := FormatDec(A1."Base 1" + A1."Base 2" + A1."Base 3");
        rez_pren23 := FormatDec(B1."Base 1");
        rez_pren5 := FormatDec(B1."Base 2" + B1."Base 3");
    end;

    local procedure CalcTotalAmountsBuffer(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
        TempVATCtrlReportBufferCZL.Reset();
        TempVATCtrlReportBufferCZL.SetFilter("Corrections for Bad Receivable", '%1|%2',
            TempVATCtrlReportBufferCZL."Corrections for Bad Receivable"::" ",
            TempVATCtrlReportBufferCZL."Corrections for Bad Receivable"::"Bad Receivable (p.46 resp. 74a)");
        TempVATCtrlReportBufferCZL.CalcSums("Base 1", "Base 2", "Base 3");
    end;

    local procedure SkipEmptyValue(Value: Text[1024])
    begin
        if Value = '' then
            currXMLport.Skip();
    end;

    local procedure FormatDec(DecLoc: Decimal): Text
    begin
        exit(Format(DecLoc, 0, '<Sign><Integer><Decimals><Comma,.>'));
    end;

    local procedure FormatInt(IntLoc: Integer): Text
    begin
        exit(Format(IntLoc, 0, 1));
    end;

    local procedure FormatDate(DateLoc: Date): Text
    begin
        exit(Format(DateLoc, 0, '<Day,2>.<Month,2>.<Year4>'));
    end;

    local procedure FormatVATRegistration(VATRegistration: Text): Text
    begin
        exit(CopyStr(VATRegistration, 3));
    end;

    local procedure FormatFastAppelReaction(FastAppelReaction: Option " ",B,P): Text
    begin
        case FastAppelReaction of
            FastAppelReaction::" ":
                exit('');
            FastAppelReaction::B:
                exit('B');
            FastAppelReaction::P:
                exit('P');
        end;
    end;

    local procedure ConvertDeclarationType(DeclarationType: Enum "VAT Ctrl. Report Decl Type CZL"): Text
    begin
        case DeclarationType of
            DeclarationType::Recapitulative:
                exit('B');
            DeclarationType::"Recapitulative-Corrective":
                exit('O');
            DeclarationType::Supplementary:
                exit('N');
            DeclarationType::"Supplementary-Corrective":
                exit('E');
        end;
    end;

    local procedure ConvertCorrectionsForBadReceivable(CorrectionsForBadReceivable: Enum "VAT Ctrl. Report Corect. CZL"): Text[1];
    begin
        case CorrectionsForBadReceivable of
            CorrectionsForBadReceivable::" ":
                exit('N');
            CorrectionsForBadReceivable::"Insolvency Proceedings (p.44)":
                exit('A');
            CorrectionsForBadReceivable::"Bad Receivable (p.46 resp. 74a)":
                begin
                    if VATCtrlReportFormatCZL = VATCtrlReportFormatCZL::"02_01_03" then
                        exit('A');
                    exit('P');
                end;
        end;
    end;

    local procedure GetCountryCodeFromVATRegistrationNo(VATRegistrationNo: Code[20]): Code[20]
    begin
        if not (CopyStr(VATRegistrationNo, 1, 1) in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
            exit(CopyStr(VATRegistrationNo, 1, 2));
        exit('');
    end;
}
