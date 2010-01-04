
module Derive.Test(test) where

import Derive.Utils
import Language.Haskell.Exts
import Data.Derive.DSL.HSE
import Data.DeriveDSL
import Control.Monad
import Data.Maybe
import Data.List
import System.FilePath
import System.Directory
import System.Cmd
import System.Exit
import Control.Arrow
import Data.Char
import Data.Derive.All
import Data.Derive.Internal.Derivation


-- These overlap with other derivations
overlaps =
    [["BinaryDefer","EnumCyclic","LazySet","DataAbstract"]]

-- REASONS:
-- UniplateDirect: Doesn't work through Template Haskell
exclude = ["ArbitraryOld","UniplateDirect","Ref","Serial"]

-- These must be first and in every set
priority = ["Eq","Typeable"]


listType :: Decl
listType = DataDecl sl DataType [] (Ident "[]") [UnkindedVar $ Ident "a"]
    [QualConDecl sl [] [] (ConDecl (Ident "[]") [])
    ,QualConDecl sl [] [] (ConDecl (Ident "Cons")
        [UnBangedTy (TyVar (Ident "a"))
        ,UnBangedTy (TyApp (TyCon (UnQual (Ident "List"))) (TyVar (Ident "a")))])]
    []


-- test each derivation
test :: IO ()
test = do
    decls <- fmap (filter isDataDecl . moduleDecls) $ readHSE "Data/Derive/Internal/Test.hs"

    -- check the test bits
    let ts = ("[]",listType) : map (dataDeclName &&& id) decls
    mapM_ (testFile ts) derivations

    -- check the $(derive) bits
    putStrLn "Type checking examples"
    let name = "AutoGenerated_Test"
    devs <- sequence [liftM ((,) d) $ readSrc $ "Data/Derive" </> derivationName d <.> "hs" | d <- derivations]
    let lookupDev x = fromMaybe (error $ "Couldn't find derivation: " ++ x) $ find ((==) x . derivationName . fst) devs

    let sets = zip [1..] $ map (map lookupDev) $ map (priority++) $
            [d | d <- map (derivationName . fst) devs, d `notElem` (exclude ++ priority ++ concat overlaps)] : overlaps

    forM sets $ \(i,xs) -> autoTest (name++show i) decls xs
    writeFile (name++".hs") $ unlines $
        ["import " ++ name ++ show (fst i) | i <- sets] ++ ["main = putStrLn \"Type checking successful\""]
    res <- system $ "runhaskell " ++ name ++ ".hs"
    when (res /= ExitSuccess) $ error "Failed to typecheck results"


testFile :: [(String,Decl)] -> Derivation -> IO ()
testFile types (Derivation name op) = do
    putStrLn $ "Testing " ++ name
    src <- readSrc $ "Data/Derive/" ++ name ++ ".hs"
    forM_ (srcTest src) $ \(typ,res) -> do
        let d = if tyRoot typ /= name then tyRoot typ else tyRoot $ head $ snd $ fromTyApps $ fromTyParen typ
        let grab x = fromMaybe (error $ "Error in tests, couldn't resolve type: " ++ x) $ lookup x types
        let Right r = op typ grab (ModuleName "Example", grab d)
        when (not $ r `outEq` res) $
            error $ "Results don't match!\nExpected:\n" ++ showOut res ++ "\nGot:\n" ++ showOut r ++ "\n\n" ++ detailedNeq res r

detailedNeq as bs | na /= nb = "Lengths don't match, " ++ show na ++ " vs " ++ show nb
    where na = length as ; nb = length bs

detailedNeq as bs = "Mismatch on line " ++ show i ++ "\n" ++ show a ++ "\n" ++ show b
    where (i,a,b) = head $ filter (\(i,a,b) -> a /= b) $ zip3 [1..] (noSl as) (noSl bs)


autoTest :: String -> [DataDecl] -> [(Derivation,Src)] -> IO ()
autoTest name ts ds =
    writeFile (name++".hs") $ unlines $
        ["{-# LANGUAGE TemplateHaskell,FlexibleInstances,MultiParamTypeClasses,TypeOperators #-}"
        ,"{-# OPTIONS_GHC -Wall -fno-warn-missing-fields -fno-warn-unused-imports #-}"
        ,"module " ++ name ++ " where"
        ,"import Prelude"
        ,"import Data.DeriveTH"
        ,"import Derive.TestInstances()"] ++
        [prettyPrint i | (_,s) <- ds, i <- srcImportStd s] ++
        [prettyPrint t | t <- ts2] ++
        ["$(derives [make" ++ derivationName d ++ "] " ++ types ++ ")" | (d,_) <- ds]
    where
        types = "[" ++ intercalate "," ["''" ++ dataDeclName t | t <- ts2] ++ "]"
        ts2 = filter (not . isBuiltIn) ts

isBuiltIn x = dataDeclName x `elem` ["Bool","Either"]
