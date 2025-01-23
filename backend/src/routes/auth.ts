import { Router, Request, Response } from "express";

const authRouter = Router();

interface SignUpBody{
    name:String;
    email:String;
    password:String;
}

authRouter.post("/signup",async (req:Request<{},{},SignUpBody>,res:Response)=>{
    try {
        
    } catch (error) {
        
    }
})

authRouter.get('/',(req,res)=>{
    res.send("hi there! from authiii");
});

export default authRouter;