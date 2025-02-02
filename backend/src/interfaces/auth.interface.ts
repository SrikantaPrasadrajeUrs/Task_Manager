interface SignUpBody{
    name:string;
    email:string;
    password:string;
}

interface LoginBody{
    email:string;
    password:string;
}

export {SignUpBody,LoginBody};