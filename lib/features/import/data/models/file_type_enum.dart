enum FileType {
    TIEDONTUOTTAJAT('Tiedontuottajat'),
    TAAJAMAT('asukkaan taajamat'),
    POSTINUMEROT('PCF'),
    DVVTIEDOSTO('DVV-aineisto'),
    HUONEISTOMAARAT('Huoneistomäärät'),
    PERUSMAKSUAINEISTO('Perusmaksuaineisto'),
    HAPATIEDOSTO('Hapa-kohteet'),
    KAIVOTIEDOT_ALKU('Kaivotiedot_aloitus'),
    KAIVOTIEDOT_LOPPU('Kaivotiedot_lopetus'),
    VIEMARIVERKOSTO_ALKU('Viemariverkosto'),
    VIEMARIVERKOSTO_LOPPU('Viemäriverkosto_lopetus'),
    KULJETUSTIETO_LIETE('Liete_kuljetustiedot'),
    PAATOSTIEDOSTO('Paatokset'),
    ILMOITUSTIEDOSTO('Kompostointi_ilmoitukset'),
    LIETE_KOMPOSTOINTI('Lietteen_kompostointi'),
    KOMPOSTOINNIN_LOPETUS('Kompostoinnin_lopettami'),
    KULJETUSTIETO('Salpakierto'),
    LIETE_PELTOLEVITYS('Lietteenpeltolevitys');

    const FileType(this.type);
    final String type;
}
