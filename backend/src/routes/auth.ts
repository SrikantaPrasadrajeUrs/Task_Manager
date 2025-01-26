import { Router, Request, Response } from "express";
import { db } from "../db";
import { eq } from "drizzle-orm";
import { users , NewUser, User } from "../db/schema";
import bcrypt from "bcryptjs"
import jwt from "jsonwebtoken"
import {secret} from "../index"


const authRouter = Router();

interface SignUpBody{
    name:string;
    email:string;
    password:string;
}

interface LoginBody{
    email:string;
    password:string;
}

authRouter.post("/signup",async (req:Request<{},{},SignUpBody>,res:Response)=>{
    try {
      const { name, email, password } = req.body;
      // check if the user already exists
      const [existingUser] = await db
        .select()
        .from(users)
        .where(eq(users.email, email));
        if(existingUser){
            res.status(400).json({message:"User email is already exist"});
            return;
        }

           let hasedPassword = await bcrypt.hash(password,7);
           let newUser:NewUser = {
            name,
            email,
            password:hasedPassword
           };
           const [storedUser] = await db.insert(users).values(newUser).returning();
           res.status(201).json({message:"",userData:storedUser});
    } catch (error) {
       res.status(500).json({error: error}); 
    }
});

authRouter.post("/login",async (req:Request<{},{},LoginBody>,res:Response)=>{
    try {
      const { email, password } = req.body;
      // check if the user already exists
      const [existingUser] = await db
        .select()
        .from(users)
        .where(eq(users.email, email));
        if(!existingUser){
            res.status(400).json({message:"Email does not exist"});
            return;
        }

           let isMatched = await bcrypt.compare(password,existingUser.password);
           if(!isMatched){
            res.status(400).json({"message":"Incorrect password"});
           }
           if(!secret){
            res.status(400).json({"message":"Internal server error"});
           }
           jwt.sign({id: existingUser.id},secret!);
           res.json({existingUser});
    } catch (error) {
       res.status(500).json({error: error}); 
    }
})

export default authRouter;