document.addEventListener("DOMContentLoaded", () => {

    const registerForm = document.getElementById("register-form");

    if (registerForm !== null) {
        const address = document.getElementById("registration_user_address");
        const situations = [
            document.getElementById("registration_user_situation_living"),
            document.getElementById("registration_user_situation_working"),
            document.getElementById("registration_user_situation_other")
        ];

        const checkAddress = (element) => {
            if (element.checked && element === situations[0]) {
                address.parentElement.parentElement.classList.remove("hide")
            } else {
                address.parentElement.parentElement.classList.add("hide")
            }
        };

        situations.forEach((item) => {
            item.addEventListener("change", (e) => {
                checkAddress(e.target)
            })
        })
    }
});