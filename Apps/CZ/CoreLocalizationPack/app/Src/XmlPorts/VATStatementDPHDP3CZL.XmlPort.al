// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Utilities;

xmlport 11766 "VAT Statement DPHDP3 CZL"
{
    Caption = 'VAT Statement DPHDP3';
    Direction = Export;
    Encoding = UTF8;
    Format = Xml;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;

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
            tableelement(vatstatementname; "VAT Statement Name")
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'DPHDP3';

                textattribute(xmlversion)
                {
                    Occurrence = Optional;
                    XmlName = 'verzePis';
                }
                textelement(VetaD)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    textattribute(formtype)
                    {
                        XmlName = 'dapdph_forma';

                        trigger OnBeforePassVariable()
                        begin
                            FormType := VATStmtXMLExportHelperCZL.ConvertToFormType(DeclarationType);
                        end;
                    }
                    textattribute(vatyear)
                    {
                        Occurrence = Required;
                        XmlName = 'rok';
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
                    textattribute(mainecactcode1)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_okec';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(MainEcActCode1);
                        end;
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
                    textattribute(vatmonth)
                    {
                        Occurrence = Optional;
                        XmlName = 'mesic';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(vatmonth);
                        end;
                    }
                    textattribute(documentformat)
                    {
                        Occurrence = Required;
                        XmlName = 'dokument';

                        trigger OnBeforePassVariable()
                        begin
                            documentformat := 'DP3';
                        end;
                    }
                    textattribute(todaydate)
                    {
                        Occurrence = Optional;
                        XmlName = 'd_poddp';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(TodayDate);
                        end;
                    }
                    textattribute(vatquarter)
                    {
                        Occurrence = Optional;
                        XmlName = 'ctvrt';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(vatquarter);
                        end;
                    }
                    textattribute(taxpayerstatus)
                    {
                        Occurrence = Required;
                        XmlName = 'typ_platce';
                    }
                    textattribute(trans)
                    {
                        Occurrence = Optional;
                        XmlName = 'trans';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(trans);
                        end;
                    }
                    textattribute(partialvatperiodstart)
                    {
                        XmlName = 'zdobd_od';
                    }
                    textattribute(partialvatperiodend)
                    {
                        XmlName = 'zdobd_do';
                    }
                    textattribute(nextyearvatperiodcode)
                    {
                        XmlName = 'kod_zo';
                    }
                }
                textelement(VetaP)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    textattribute(authemplastname)
                    {
                        Occurrence = Optional;
                        XmlName = 'opr_prijmeni';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(AuthEmpLastName);
                        end;
                    }
                    textattribute(individualfirstname)
                    {
                        Occurrence = Optional;
                        XmlName = 'jmeno';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(individualfirstname);
                        end;
                    }
                    textattribute(compemail)
                    {
                        Occurrence = Optional;
                        XmlName = 'email';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(CompEmail);
                        end;
                    }
                    textattribute(street)
                    {
                        Occurrence = Optional;
                        XmlName = 'ulice';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(Street);
                        end;
                    }
                    textattribute(houseno)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_pop';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(HouseNo);
                        end;
                    }
                    textattribute(individuallastname)
                    {
                        Occurrence = Optional;
                        XmlName = 'prijmeni';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(individuallastname);
                        end;
                    }
                    textattribute(compphoneno)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_telef';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(CompPhoneNo);
                        end;
                    }
                    textattribute(municipalityno)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_orient';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(MunicipalityNo);
                        end;
                    }
                    textattribute(companytradename)
                    {
                        Occurrence = Optional;
                        XmlName = 'zkrobchjm';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(CompanyTradeName);
                        end;
                    }
                    textattribute(taxofficenumber)
                    {
                        Occurrence = Required;
                        XmlName = 'c_ufo';
                    }
                    textattribute(taxofficeregionnumber)
                    {
                        Occurrence = Optional;
                        XmlName = 'c_pracufo';
                    }
                    textattribute(compregion)
                    {
                        Occurrence = Optional;
                        XmlName = 'stat';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(CompRegion);
                        end;
                    }
                    textattribute(fillempfirstname)
                    {
                        Occurrence = Optional;
                        XmlName = 'sest_jmeno';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(FillEmpFirstName);
                        end;
                    }
                    textattribute(vatregno)
                    {
                        XmlName = 'dic';
                    }
                    textattribute(city)
                    {
                        Occurrence = Optional;
                        XmlName = 'naz_obce';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(City);
                        end;
                    }
                    textattribute(postcode)
                    {
                        Occurrence = Optional;
                        XmlName = 'psc';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(PostCode);
                        end;
                    }
                    textattribute(taxpayertype)
                    {
                        Occurrence = Required;
                        XmlName = 'typ_ds';
                    }
                    textattribute(fillemplastname)
                    {
                        Occurrence = Optional;
                        XmlName = 'sest_prijmeni';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(FillEmpLastName);
                        end;
                    }
                    textattribute(individualtitle)
                    {
                        Occurrence = Optional;
                        XmlName = 'titul';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(IndividualTitle);
                        end;
                    }
                    textattribute(fillempphoneno)
                    {
                        Occurrence = Optional;
                        XmlName = 'sest_telef';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(FillEmpPhoneNo);
                        end;
                    }
                    textattribute(authempjobtitle)
                    {
                        Occurrence = Optional;
                        XmlName = 'opr_postaveni';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(AuthEmpJobTitle);
                        end;
                    }
                    textattribute(authempfirstname)
                    {
                        Occurrence = Optional;
                        XmlName = 'opr_jmeno';

                        trigger OnBeforePassVariable()
                        begin
                            SkipEmptyValue(AuthEmpFirstName);
                        end;
                    }
                    textattribute(zast_dat_nar)
                    {
                        XmlName = 'zast_dat_nar';
                    }
                    textattribute(zast_ev_cislo)
                    {
                        XmlName = 'zast_ev_cislo';
                    }
                    textattribute(zast_ic)
                    {
                        XmlName = 'zast_ic';
                    }
                    textattribute(zast_jmeno)
                    {
                        XmlName = 'zast_jmeno';
                    }
                    textattribute(zast_kod)
                    {
                        XmlName = 'zast_kod';
                    }
                    textattribute(zast_nazev)
                    {
                        XmlName = 'zast_nazev';
                    }
                    textattribute(zast_prijmeni)
                    {
                        XmlName = 'zast_prijmeni';
                    }
                    textattribute(zast_typ)
                    {
                        XmlName = 'zast_typ';
                    }
                }
                textelement(Veta1)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(dan23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan23, 'dan23');
                        end;
                    }
                    textattribute(dan_psl23_z)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_psl23_z, 'dan_psl23_z');
                        end;
                    }
                    textattribute(obrat23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(obrat23, 'obrat23');
                        end;
                    }
                    textattribute(dov_zb23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dov_zb23, 'dov_zb23');
                        end;
                    }
                    textattribute(p_sl5_z)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(p_sl5_z, 'p_sl5_z');
                        end;
                    }
                    textattribute(dan_dzb5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_dzb5, 'dan_dzb5');
                        end;
                    }
                    textattribute(p_zb5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(p_zb5, 'p_zb5');
                        end;
                    }
                    textattribute(dan_pzb5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_pzb5, 'dan_pzb5');
                        end;
                    }
                    textattribute(p_sl23_z)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(p_sl23_z, 'p_sl23_z');
                        end;
                    }
                    textattribute(dan_pzb23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_pzb23, 'dan_pzb23');
                        end;
                    }
                    textattribute(p_sl5_e)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(p_sl5_e, 'p_sl5_e');
                        end;
                    }
                    textattribute(p_zb23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(p_zb23, 'p_zb23');
                        end;
                    }
                    textattribute(dan_pdop_nrg)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_pdop_nrg, 'dan_pdop_nrg');
                        end;
                    }
                    textattribute(p_sl23_e)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(p_sl23_e, 'p_sl23_e');
                        end;
                    }
                    textattribute(dov_zb5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dov_zb5, 'dov_zb5');
                        end;
                    }
                    textattribute(dan_psl5_z)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_psl5_z, 'dan_psl5_z');
                        end;
                    }
                    textattribute(obrat5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(obrat5, 'obrat5');
                        end;
                    }
                    textattribute(dan_dzb23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_dzb23, 'dan_dzb23');
                        end;
                    }
                    textattribute(p_dop_nrg)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(p_dop_nrg, 'p_dop_nrg');
                        end;
                    }
                    textattribute(dan5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan5, 'dan5');
                        end;
                    }
                    textattribute(dan_psl23_e)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_psl23_e, 'dan_psl23_e');
                        end;
                    }
                    textattribute(dan_psl5_e)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_psl5_e, 'dan_psl5_e');
                        end;
                    }
                    textattribute(dan_rpren23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_rpren23, 'dan_rpren23');
                        end;
                    }
                    textattribute(dan_rpren5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_rpren5, 'dan_rpren5');
                        end;
                    }
                    textattribute(rez_pren23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(rez_pren23, 'rez_pren23');
                        end;
                    }
                    textattribute(rez_pren5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(rez_pren5, 'rez_pren5');
                        end;
                    }
                }
                textelement(Veta2)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(pln_vyvoz)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(pln_vyvoz, 'pln_vyvoz');
                        end;
                    }
                    textattribute(pln_ost)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(pln_ost, 'pln_ost');
                        end;
                    }
                    textattribute(dod_dop_nrg)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dod_dop_nrg, 'dod_dop_nrg');
                        end;
                    }
                    textattribute(dod_zb)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dod_zb, 'dod_zb');
                        end;
                    }
                    textattribute(pln_sluzby)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(pln_sluzby, 'pln_sluzby');
                        end;
                    }
                    textattribute(pln_zaslani)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(pln_zaslani, 'pln_zaslani');
                        end;
                    }
                    textattribute(pln_rez_pren)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(pln_rez_pren, 'pln_rez_pren');
                        end;
                    }
                }
                textelement(Veta3)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(tri_pozb)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(tri_pozb, 'tri_pozb');
                        end;
                    }
                    textattribute(tri_dozb)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(tri_dozb, 'tri_dozb');
                        end;
                    }
                    textattribute(dov_osv)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dov_osv, 'dov_osv');
                        end;
                    }
                    textattribute(opr_dluz)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(opr_dluz, 'opr_dluz');
                        end;
                    }
                    textattribute(opr_verit)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(opr_verit, 'opr_verit');
                        end;
                    }
                }
                textelement(Veta4)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(odp_tuz5_nar)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_tuz5_nar, 'odp_tuz5_nar');
                        end;
                    }
                    textattribute(odp_sum_nar)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_sum_nar, 'odp_sum_nar');
                        end;
                    }
                    textattribute(odp_tuz5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_tuz5, 'odp_tuz5');
                        end;
                    }
                    textattribute(odp_rezim)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_rezim, 'odp_rezim');
                        end;
                    }
                    textattribute(odp_sum_kr)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_sum_kr, 'odp_sum_kr');
                        end;
                    }
                    textattribute(pln23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(pln23, 'pln23');
                        end;
                    }
                    textattribute(odp_rez_nar)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_rez_nar, 'odp_rez_nar');
                        end;
                    }
                    textattribute(odp_tuz23_nar)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_tuz23_nar, 'odp_tuz23_nar');
                        end;
                    }
                    textattribute(pln5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(pln5, 'pln5');
                        end;
                    }
                    textattribute(odp_tuz23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_tuz23, 'odp_tuz23');
                        end;
                    }
                    textattribute(nar_maj)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(nar_maj, 'nar_maj');
                        end;
                    }
                    textattribute(nar_zdp23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(nar_zdp23, 'nar_zdp23');
                        end;
                    }
                    textattribute(nar_zdp5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(nar_zdp5, 'nar_zdp5');
                        end;
                    }
                    textattribute(od_maj)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(od_maj, 'od_maj');
                        end;
                    }
                    textattribute(odkr_zdp23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odkr_zdp23, 'odkr_zdp23');
                        end;
                    }
                    textattribute(od_zdp23)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(od_zdp23, 'od_zdp23');
                        end;
                    }
                    textattribute(odkr_maj)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odkr_maj, 'odkr_maj');
                        end;
                    }
                    textattribute(od_zdp5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(od_zdp5, 'od_zdp5');
                        end;
                    }
                    textattribute(odkr_zdp5)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odkr_zdp5, 'odkr_zdp5');
                        end;
                    }
                    textattribute(dov_cu)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dov_cu, 'dov_cu');
                        end;
                    }
                    textattribute(odp_cu)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_cu, 'odp_cu');
                        end;
                    }
                    textattribute(odp_cu_nar)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_cu_nar, 'odp_cu_nar');
                        end;
                    }
                }
                textelement(Veta5)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(odp_uprav_kf)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_uprav_kf, 'odp_uprav_kf');
                        end;
                    }
                    textattribute(vypor_odp)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(vypor_odp, 'vypor_odp');
                        end;
                    }
                    textattribute(koef_p20_nov)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(koef_p20_nov, 'koef_p20_nov');
                        end;
                    }
                    textattribute(plnosv_nkf)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(plnosv_nkf, 'plnosv_nkf');
                        end;
                    }
                    textattribute(koef_p20_vypor)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(koef_p20_vypor, 'koef_p20_vypor');
                        end;
                    }
                    textattribute(pln_nkf)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(pln_nkf, 'pln_nkf');
                        end;
                    }
                    textattribute(plnosv_kf)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(plnosv_kf, 'plnosv_kf');
                        end;
                    }
                }
                textelement(Veta6)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(dan_vrac)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_vrac, 'dan_vrac');
                        end;
                    }
                    textattribute(dano)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dano, 'dano');
                            if (dano <> '') and not DeclarationIsSupplementary() then
                                dano := '';
                        end;
                    }
                    textattribute(odp_zocelk)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(odp_zocelk, 'odp_zocelk');
                            CalcVatPeriodTotals();
                        end;
                    }
                    textattribute(dano_no)
                    {
                        Occurrence = Optional;
                    }
                    textattribute(dan_zocelk)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(dan_zocelk, 'dan_zocelk');
                            CalcVatPeriodTotals();
                        end;
                    }
                    textattribute(dano_da)
                    {
                        Occurrence = Optional;
                    }
                    textattribute(uprav_odp)
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassVariable()
                        begin
                            GetAmtAndSkipIfEmpty(uprav_odp, 'uprav_odp');
                        end;
                    }
                }
                tableelement(commentline; "VAT Statement Comment Line CZL")
                {
                    LinkFields = "VAT Statement Template Name" = field("Statement Template Name"), "VAT Statement Name" = field(Name);
                    LinkTable = VATStatementName;
                    MinOccurs = Zero;
                    XmlName = 'VetaR';
                    textattribute(sectioncode)
                    {
                        Occurrence = Optional;
                        XmlName = 'kod_sekce';
                    }
                    textattribute(commentlineno)
                    {
                        XmlName = 'poradi';
                    }
                    fieldattribute(t_prilohy; CommentLine.Comment)
                    {
                        Occurrence = Optional;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        ElementCounter += 1;
                        CommentLineNo := Format(ElementCounter);
                        SectionCode := VATStmtXMLExportHelperCZL.ConvertToSectionCode(DeclarationType);
                    end;

                    trigger OnPreXmlItem()
                    begin
                        if not DeclarationIsSupplementary() then
                            currXMLport.Break();
                        commentline.SetRange(Date, StartDate, EndDate);
                        ElementCounter := 0;
                    end;
                }
                textelement(Prilohy)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(attachment; "VAT Statement Attachment CZL")
                    {
                        LinkFields = "VAT Statement Template Name" = field("Statement Template Name"), "VAT Statement Name" = field(Name);
                        LinkTable = VATStatementName;
                        MinOccurs = Zero;
                        XmlName = 'ObecnaPriloha';
                        SourceTableView = where("File Name" = filter(<> ''));
                        textattribute(attachmentno)
                        {
                            XmlName = 'cislo';
                        }
                        fieldattribute(nazev; Attachment.Description)
                        {
                            Occurrence = Optional;
                        }
                        fieldattribute(jm_souboru; Attachment."File Name")
                        {
                            Occurrence = Optional;
                        }
                        textattribute(kodovani)
                        {
                            Occurrence = Optional;

                            trigger OnBeforePassVariable()
                            begin
                                kodovani := 'base64';
                            end;
                        }
                        trigger OnAfterGetRecord()
                        begin
                            ElementCounter += 1;
                            AttachmentNo := Format(ElementCounter);
                        end;

                        trigger OnPreXmlItem()
                        begin
                            if not DeclarationIsSupplementary() then
                                currXMLport.Break();
                            attachment.SetRange(Date, StartDate, EndDate);
                            ElementCounter := 0;
                        end;
                    }
                }
                trigger OnPreXmlItem()
                begin
                    VATStatementName.SetRange("Statement Template Name", VATStatementTemplateName);
                    VATStatementName.SetRange(Name, VATStatementNameCode);
                end;

                trigger OnAfterGetRecord()
                var
                    VATStatementLine: Record "VAT Statement Line";
                begin
                    if XMLTagAmount.Count() <> 0 then
                        exit;

                    VATStatementLine.Reset();
                    VATStatementLine.SetRange("Statement Template Name", VATStatementName."Statement Template Name");
                    VATStatementLine.SetRange("Statement Name", VATStatementName.Name);
                    VATStatementLine.SetRange("Date Filter", StartDate, EndDate);
                    VATStatementLine.SetRange(Print, true);
                    VATStatementLine.SetFilter("Attribute Code CZL", '<>%1', '');
                    if VATStatementLine.FindSet() then
                        repeat
                            AddAmount(GetXMLTag(VATStatementLine), GetColumnValue(VATStatementLine));
                        until VATStatementLine.Next() = 0;
                end;

            }
        }
    }
    trigger OnPreXmlPort()
    begin
        LoadXMLParams();
        PrepareExportData();
        CheckRestrictions();
    end;

    var
        CompanyInformation: Record "Company Information";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        VATStatementTemplate: Record "VAT Statement Template";
        VATStmtXMLExportHelperCZL: Codeunit "VAT Stmt XML Export Helper CZL";
        NoTaxBoolean: Boolean;
        PrintInIntegers: Boolean;
        UseAmtsInAddCurr: Boolean;
        FilledByEmployeeCode: Code[20];
        XMLTagAmount: Dictionary of [Code[20], Decimal];
        StartDate: Date;
        EndDate: Date;
        ReasonsObservedOnDate: Date;
        Month: Integer;
        Quarter: Integer;
        Year: Integer;
        ElementCounter: Integer;
        Selection: Enum "VAT Statement Report Selection";
        PeriodSelection: Enum "VAT Statement Report Period Selection";
        DeclarationType: Enum "VAT Stmt. Declaration Type CZL";
        RoundingDirection: Option Nearest,Down,Up;
        XmlParams: Text;
        VATStatementTemplateName: Code[10];
        VATStatementNameCode: Code[10];
        SettlementNoFilter: Text[50];
        SWNameTxt: Label 'Microsoft Dynamics 365 Business Central', Locked = true;
        MonthOrQuarterErr: Label 'Month or Quarter must be filled in.';
        ReasonObserverReqErr: Label 'You must specify Reasons Observed On date in Supplementary or Supplementary/Corrective VAT Statement.';
        ValueTooLongErr: Label '%1 length must not be greater than %2.', Comment = '%1 = fieldcaption; %2 = length';
        XMLVersionTok: Label '01.02', Locked = true;

    procedure ClearVariables()
    begin
        ClearAll();
    end;

    procedure SetData(var VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL")
    begin
        if VATStmtReportLineDataCZL.FindSet() then
            repeat
                AddAmount(VATStmtReportLineDataCZL."XML Code", VATStmtReportLineDataCZL.Amount);
            until VATStmtReportLineDataCZL.Next() = 0;
    end;

    procedure SetXMLParams(NewXMLParams: Text)
    begin
        XmlParams := NewXMLParams;
    end;

    local procedure LoadXMLParams()
    var
        ParamsXmlDoc: XmlDocument;
    begin
        VATStmtXMLExportHelperCZL.GetParametersXmlDoc(XmlParams, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetVATStatementName(VATStatementTemplateName, VATStatementNameCode, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetPeriod(StartDate, EndDate, Month, Quarter, Year, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetSelection(Selection, PeriodSelection, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetRounding(PrintInIntegers, RoundingDirection, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetDeclarationAndFilledBy(DeclarationType, FilledByEmployeeCode, ParamsXmlDoc);
        VATStmtXMLExportHelperCZL.GetAdditionalParams(ReasonsObservedOnDate, NextYearVATPeriodCode, SettlementNoFilter, NoTaxBoolean, UseAmtsInAddCurr, ParamsXmlDoc);
    end;

    local procedure PrepareExportData()
    var
        CompanyOfficialCZL: Record "Company Official CZL";
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        StatutoryReportingSetupCZL.Get();
        CompanyInformation.Get();

        SWVersion := ApplicationSystemConstants.ApplicationVersion();
        SWName := SWNameTxt;
        XMLVersion := XMLVersionTok;

        VATStatementTemplate.Get(VATStatementTemplateName);
        VATStatementName.Get(VATStatementTemplateName, VATStatementNameCode);

        if EndDate = 0D then
            EndDate := DMY2Date(31, 12, 9999);

        if Month <> 0 then
            vatmonth := Format(Month);
        if Quarter <> 0 then
            vatquarter := Format(Quarter);
        if Year <> 0 then
            vatyear := Format(Year);

        if ReasonsObservedOnDate <> 0D then
            ReasonsObservedOn := FormatDate(ReasonsObservedOnDate);

        TodayDate := FormatDate(Today());
        TaxPayerStatus := VATStmtXMLExportHelperCZL.ConvertTaxPayerStatus(StatutoryReportingSetupCZL."Tax Payer Status");

        SetPartialVATPeriod();

        MainEcActCode1 :=
          CheckLen(StatutoryReportingSetupCZL."Primary Business Activity Code",
            StatutoryReportingSetupCZL.FieldCaption("Primary Business Activity Code"), 6);
        TaxOfficeNumber :=
          CheckLen(StatutoryReportingSetupCZL."Tax Office Number", StatutoryReportingSetupCZL.FieldCaption("Tax Office Number"), 3);

        if StatutoryReportingSetupCZL."Tax Office Region Number" <> '' then
            TaxOfficeRegionNumber :=
              CheckLen(StatutoryReportingSetupCZL."Tax Office Region Number",
                StatutoryReportingSetupCZL.FieldCaption("Tax Office Region Number"), 4);

        if CopyStr(CompanyInformation."VAT Registration No.", 1, 2) = CompanyInformation."Country/Region Code" then
            VATRegNo := CopyStr(CompanyInformation."VAT Registration No.", 3)
        else
            VATRegNo := CompanyInformation."VAT Registration No.";

        TaxPayerType := VATStmtXMLExportHelperCZL.ConvertSubjectType(StatutoryReportingSetupCZL."Company Type");

        IndividualFirstname :=
          CheckLen(StatutoryReportingSetupCZL."Individual First Name", StatutoryReportingSetupCZL.FieldCaption("Individual First Name"), 20);
        IndividualLastname := StatutoryReportingSetupCZL."Individual Surname";
        IndividualTitle :=
          CheckLen(StatutoryReportingSetupCZL."Individual Title", StatutoryReportingSetupCZL.FieldCaption("Individual Title"), 10);

        CompanyTradeName := StatutoryReportingSetupCZL."Company Trade Name";
        City := StatutoryReportingSetupCZL.City;
        Street := CheckLen(StatutoryReportingSetupCZL.Street, StatutoryReportingSetupCZL.FieldCaption(Street), 38);
        HouseNo := CheckLen(StatutoryReportingSetupCZL."House No.", StatutoryReportingSetupCZL.FieldCaption("House No."), 6);
        MunicipalityNo :=
          CheckLen(StatutoryReportingSetupCZL."Municipality No.", StatutoryReportingSetupCZL.FieldCaption("Municipality No."), 4);
        PostCode := CheckLen(DelChr(CompanyInformation."Post Code", '=', ' '), CompanyInformation.FieldCaption("Post Code"), 5);

        StatutoryReportingSetupCZL.TestField("VAT Stat. Auth. Employee No.");
        CompanyOfficialCZL.Get(StatutoryReportingSetupCZL."VAT Stat. Auth. Employee No.");
        AuthEmpLastName := CompanyOfficialCZL."Last Name";
        AuthEmpFirstName := CheckLen(CompanyOfficialCZL."First Name", CompanyOfficialCZL.FieldCaption("First Name"), 20);
        AuthEmpJobTitle := CompanyOfficialCZL."Job Title";

        CompanyOfficialCZL.Get(FilledByEmployeeCode);
        FillEmpLastName := CompanyOfficialCZL."Last Name";
        FillEmpFirstName := CheckLen(CompanyOfficialCZL."First Name", CompanyOfficialCZL.FieldCaption("First Name"), 20);
        FillEmpPhoneNo := CheckLen(CompanyOfficialCZL."Phone No.", CompanyOfficialCZL.FieldCaption("Phone No."), 14);

        trans := VATStmtXMLExportHelperCZL.ConvertBoolean(not (NoTaxBoolean));

        CompEmail := CompanyInformation."E-Mail";
        CompPhoneNo := CheckLen(CompanyInformation."Phone No.", CompanyInformation.FieldCaption("Phone No."), 14);
        CompRegion := StatutoryReportingSetupCZL."VAT Statement Country Name";

        zast_kod := StatutoryReportingSetupCZL."Official Code";
        zast_typ := VATStmtXMLExportHelperCZL.ConvertSubjectType(StatutoryReportingSetupCZL."Official Type");
        zast_nazev := StatutoryReportingSetupCZL."Official Name";
        zast_jmeno := StatutoryReportingSetupCZL."Official First Name";
        zast_prijmeni := StatutoryReportingSetupCZL."Official Surname";
        zast_dat_nar := FormatDate(StatutoryReportingSetupCZL."Official Birth Date");
        zast_ev_cislo := StatutoryReportingSetupCZL."Official Reg.No.of Tax Adviser";
        zast_ic := StatutoryReportingSetupCZL."Official Registration No.";
    end;

    local procedure CheckRestrictions()
    begin
        if (Month = 0) and (Quarter = 0) then
            Error(MonthOrQuarterErr);

        if DeclarationIsSupplementary() then
            if ReasonsObservedOnDate = 0D then
                Error(ReasonObserverReqErr);
    end;

    local procedure DeclarationIsSupplementary(): Boolean
    begin
        exit(DeclarationType in [DeclarationType::Supplementary, DeclarationType::"Supplementary/Corrective"])
    end;

    local procedure CheckLen(FieldValue: Text[50]; FieldCaption: Text; MaxLen: Integer): Text[50]
    begin
        if StrLen(FieldValue) > MaxLen then
            Error(ValueTooLongErr, FieldCaption, MaxLen);
        exit(FieldValue);
    end;

    local procedure CalcVatPeriodTotals()
    var
        HasOutputTax: Boolean;
        HasVATDeduction: Boolean;
        OutputTax: Decimal;
        VATDeduction: Decimal;
    begin
        HasVATDeduction := XMLTagAmount.Get(CopyStr(UpperCase('odp_zocelk'), 1, 20), VATDeduction);
        HasOutputTax := XMLTagAmount.Get(CopyStr(UpperCase('dan_zocelk'), 1, 20), OutputTax);
        case true of
            (HasVATDeduction and HasOutputTax):
                if VATDeduction < OutputTax then
                    SetVATLiability()
                else
                    SetExcessVATDeduction();
            (HasVATDeduction and not HasOutputTax):
                SetExcessVATDeduction();
            (HasOutputTax and not HasVATDeduction):
                SetVATLiability();
        end;
    end;

    local procedure SetVATLiability()
    begin
        dano_no := '';
        if not DeclarationIsSupplementary() then begin
            dano_da := GetAmount('dano_da');
            dano_da := DelChr(dano_da, '=', '-');
        end;
    end;

    local procedure SetExcessVATDeduction()
    begin
        dano_da := '';
        if not DeclarationIsSupplementary() then begin
            dano_no := GetAmount('dano_no');
            dano_no := DelChr(dano_no, '=', '-');
        end;
    end;

    local procedure GetAmount(XMLTag: Code[20]): Text[14]
    var
        BufferAmount: Decimal;
    begin
        if XMLTagAmount.Get(XMLTag, BufferAmount) then
            if BufferAmount <> 0 then
                exit(Format(BufferAmount, 0, 9));
        exit('');
    end;

    procedure AddAmount(XMLTag: Code[20]; Amount: Decimal)
    var
        BufferAmount: Decimal;
    begin
        if XMLTagAmount.Get(XMLTag, BufferAmount) then
            XMLTagAmount.Set(XMLTag, BufferAmount + Amount)
        else
            XMLTagAmount.Add(XMLTag, Amount);
    end;

    local procedure SkipEmptyValue(Value: Text[1024])
    begin
        if Value = '' then
            currXMLport.Skip();
    end;

    local procedure GetAmtAndSkipIfEmpty(var Value: Text[1024]; XMLTag: Code[20])
    begin
        Value := GetAmount(XMLTag);
        SkipEmptyValue(Value);
    end;

    local procedure SetPartialVATPeriod()
    var
        Date: Record Date;
        PeriodEndDate: Date;
        PeriodStartDate: Date;
    begin
        if Year = 0 then
            Year := Date2DMY(EndDate, 3);
        if Month <> 0 then begin
            Date.SetRange("Period Type", Date."Period Type"::Month);
            Date.SetRange("Period Start", DMY2Date(1, Month, Year));
            Date.SetRange("Period No.", Month);
            if Date.FindLast() then begin
                PeriodStartDate := NormalDate(Date."Period Start");
                PeriodEndDate := NormalDate(Date."Period End");
            end;
        end else begin
            Date.SetRange("Period Type", Date."Period Type"::Quarter);
            Date.SetRange("Period Start", DMY2Date(1, 1, Year), DMY2Date(31, 12, Year));
            Date.SetRange("Period No.", Quarter);
            if Date.FindLast() then begin
                PeriodStartDate := NormalDate(Date."Period Start");
                PeriodEndDate := NormalDate(Date."Period End");
            end;
        end;

        if (PeriodStartDate = StartDate) and (PeriodEndDate = EndDate) then
            exit;
        partialvatperiodstart := FormatDate(StartDate);
        partialvatperiodend := FormatDate(EndDate);
    end;

    local procedure FormatDate(Date: Date): Text
    begin
        exit(Format(Date, 0, '<Day,2>.<Month,2>.<Year4>'));
    end;

    local procedure GetXMLTag(VATStatementLine: Record "VAT Statement Line"): Code[20]
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
    begin
        VATAttributeCodeCZL.Get(VATStatementLine."Statement Template Name", VATStatementLine."Attribute Code CZL");
        VATAttributeCodeCZL.TestField("XML Code");
        exit(VATAttributeCodeCZL."XML Code");
    end;

    local procedure GetColumnValue(var VATStatementLine: Record "VAT Statement Line") ColumnValue: Decimal
    var
        VATStatement: Report "VAT Statement";
    begin
        VATStatement.InitializeRequestCZL(
          VATStatementName, VATStatementLine, Selection,
          PeriodSelection, PrintInIntegers, UseAmtsInAddCurr,
          SettlementNoFilter, RoundingDirection);

        VATStatement.CalcLineTotal(VATStatementLine, ColumnValue, 0);
        if PrintInIntegers then
            ColumnValue := Round(ColumnValue, 1, VATStatement.GetAmtRoundingDirectionCZL());

        ColumnValue := ColumnValue;

        if VATStatementLine."Print with" = VATStatementLine."Print with"::"Opposite Sign" then
            ColumnValue := -ColumnValue;
    end;

    procedure CopyAttachmentFilter(var VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL")
    begin
        VATStatementAttachmentCZL.CopyFilters(Attachment);
    end;
}

