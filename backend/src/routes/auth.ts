import { Router, Request, Response } from "express";
import { db } from "../db";
import { eq } from "drizzle-orm";
import { users , NewUser, User } from "../db/schema";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import { SignUpBody, LoginBody } from "../interfaces";
import { loginUser, signUpUser } from "../controllers/index";

dotenv.config();

const secret:string= process.env.SECRET??"";

const authRouter = Router();

authRouter.post("/signup",signUpUser);

authRouter.post("/login",loginUser);

authRouter.post("/verifyToken",async(req,res)=>{
    try {
        const token = req.header("x-auth-token");
        
        if(!token) {
            res.status(400).json({isVerified:false})
            return;
        }
        const verified = jwt.verify(token,secret);
        if(!verified){
            res.status(400).json({isVerified:false})
            return;
        }
        const verifiedToken = verified as {id:string};
        const [user] = await db.select().from(users).where(eq(users.id,verifiedToken.id));
        if(!user){
            return;
        }
        res.json({isVerified:true,...user})
    } catch (error) {
        res.status(400).json({error,isVerified:false});
    }
})

export default authRouter;