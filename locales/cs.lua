local Translations = {
    error = {
        smash_own = "Nemůžete rozbít vozidlo, které vlastníte.",
        cannot_scrap = "Toto vozidlo nelze rozebrat.",
        not_driver = "Nejste řidičem",
        demolish_vehicle = "Nyní nemáte povoleno demolovat vozidla",
        canceled = "Zrušeno",
    },
    text = {
        scrapyard = 'Sklad starého železa',
        disassemble_vehicle = '[E] - Rozebrat vozidlo',
        disassemble_vehicle_target = 'Rozebrat vozidlo',
        email_list = "[E] - Seznam vozidel na e-mail",
        email_list_target = "Seznam vozidel na e-mail",
        demolish_vehicle = "Demolovat vozidlo",
        email_sent = "Budete dostávat seznam e-mailem za pár sekund",
    },
    email = {
        sender = "Autošrot Turner",
        subject = "Seznam vozidel",
        message = "Můžete demolovat pouze určitý počet vozidel.<br />Co rozeberete, můžete si nechat pro sebe, dokud mě nerušíte.<br /><br /><strong>Seznam vozidel:</strong><br />",
    },
}


if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
--translate by stepan_valic