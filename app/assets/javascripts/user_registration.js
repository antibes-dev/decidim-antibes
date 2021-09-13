$(document).ready(() => {
    const registerForm = $("#register-form");

    if (registerForm !== null) {
        const address = $("#registration_user_address");
        let url = new URL("https://api-adresse.data.gouv.fr/search/");

        $.extend($.ui.autocomplete.prototype, {
                _resizeMenu: () => {
                    $(".new-user-autocomplete").width(address.outerWidth());
                }
            }
        );

        const situations = [
            $("#registration_user_situation_living"),
            $("#registration_user_situation_working"),
            $("#registration_user_situation_other")
        ];

        const checkAddress = () => {
            if (situations[0].prop("checked")) {
                address.parent().parent().removeClass("hide")
            } else {
                address.parent().parent().addClass("hide")
            }
        };

        situations.forEach((item) => {
            item.on("change", () => {
                checkAddress();
            })
        });

        const build_suggestions = (addresses) => {
            if (addresses.length > 0) {
                address.autocomplete({
                    source: addresses,
                    delay: 0,
                    minLength: 0,
                    classes: {
                        "ui-autocomplete": "new-user-autocomplete"
                    }
                });
            }
        };

        const filter_api_result = (result) => {
            return result.features.map((i) => {
                return i.properties.label
            })
        };

        address.on("keyup", (e) => {
                if (address.val().length >= 5) {
                    url.searchParams.delete("q");
                    url.searchParams.delete("limit");
                    url.searchParams.append("q", e.target.value);
                    url.searchParams.append("limit", 5);

                    fetch(url,
                        {method: 'GET', redirect: 'follow'}
                    )
                        .then(response => response.text())
                        .then(result => build_suggestions(filter_api_result(JSON.parse(result))))
                        .catch(error => console.log('error', error));
                }
            }
        );

        address.on("focus", () => {
            $(".new-user-autocomplete").show();
        });
    }
});