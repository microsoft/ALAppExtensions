enum 27030 "DIOT Type of Operation"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Prof. Services") { Caption = 'Prof. Services'; }                              // 03 Prestación de Servicios Profesionales
    value(2; "Lease and Rent") { Caption = 'Lease and Rent'; }                              // 02 Enajenación de bienes
    value(3; Others) { Caption = 'Others'; }                                                // 85 Otros
    value(4; "Transfer of Goods") { Caption = 'Transfer of Goods'; }                        // 02 Enajenación de bienes
    value(5; "Import of Goods or Services") { Caption = 'Import of Goods or Services'; }    // 07 Importación de bienes o servicios
    value(6; "Import by Virtal Transfer") { Caption = 'Import by Virtal Transfer'; }        // 08 Importación por transferencia virtual
    value(7; "Global Operations") { Caption = 'Global Operations'; }                        // 87 Operaciones globales
}