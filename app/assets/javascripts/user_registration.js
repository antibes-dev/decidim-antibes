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

        const filter_api_result = (result) => {
            return result.features.map((i) => {
                return i.properties.label
            })
        };

        address.autocomplete({
            source: (request, response) => {
                url.searchParams.delete("q");
                url.searchParams.delete("limit");
                url.searchParams.delete("citycode");

                url.searchParams.append("q", request.term);
                url.searchParams.append("citycode", "06004");
                url.searchParams.append("limit", 5);

                fetch(url,
                    {method: 'GET', redirect: 'follow'}
                )
                    .then(apiResponse => apiResponse.text())
                    .then(result => response(filter_api_result(JSON.parse(result))))
                    .catch(error => console.log('error', error));
            },
            delay: 0,
            minLength: 0,
            classes: {
                "ui-autocomplete": "new-user-autocomplete"
            }
        });

        address.on("focus", () => {
            $(".new-user-autocomplete").show();
        });
    }
});