$(document).ready(() => {
    const registerForm = $("#register-form");

    if (registerForm !== null) {
        let url = new URL("https://api-adresse.data.gouv.fr/search/");
        const $address = $("#registration_user_address");
        const $addressId = $("#registration_user_address_id");

        const set_valid_address = () => {
            clear_address_state();

            $address.addClass("is-bal-valid");
        };

        const set_invalid_address = () => {
            clear_address_state();

            $address.addClass("is-bal-invalid");
        };

        const clear_address_state = () => {
            $address.removeClass("is-bal-valid");
            $address.removeClass("is-bal-invalid");
        };

        $.extend($.ui.autocomplete.prototype, {
                _resizeMenu: () => {
                    $(".new-user-autocomplete").width($address.outerWidth());
                }
            }
        );

        const filter_api_result = (result) => {
            return result.features.map((i) => {
                return {value: i.properties.label, id: i.properties.id}
            })
        };

        $address.autocomplete({
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

        $address.on("focus", () => {
            $(".new-user-autocomplete").show();
        });

        $address.on("autocompleteselect", function (event, ui) {
            $addressId.val(ui.item.id);
            set_valid_address();
        });

        $address.on("input", () => {
            $addressId.val("");
            clear_address_state();
        });

        $address.on("focusout", () => {
            if ($addressId.val() === "") {
                set_invalid_address();
            } else {
                set_valid_address();
            }
        });
    }
});