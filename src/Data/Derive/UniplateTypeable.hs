module Data.Derive.UniplateTypeable where
{-
import "uniplate" Data.Generics.Uniplate.Typeable

example :: Custom

instance (Typeable a, PlateAll a to, Uniplate to, Typeable to) => PlateAll (Sample a) to where
    plateAll (First) = plate First
    plateAll (Second x1 x2)  = plate Second |+ x1 |+ x2
    plateAll (Third x1) = plate Third |+ x1

test :: Bool

instance (Typeable to, Uniplate to) => PlateAll Bool to where
    plateAll False = plate False
    plateAll True = plate True

test :: Either a b

instance (Typeable a, PlateAll a to, Typeable b, PlateAll b to, Typeable to, Uniplate to) => PlateAll (Either a b) to where
    plateAll (Left x1) = plate Left |+ x1
    plateAll (Right x1) = plate Right |+ x1

-}

import Data.Derive.DSL.HSE

-- GENERATED START

import Data.Derive.DSL.DSL
import Data.Derive.Internal.Derivation

makeUniplateTypeable :: Derivation
makeUniplateTypeable = derivationCustomDSL "UniplateTypeable" custom $
    List [App "InstDecl" (List [App "()" (List []),App "Nothing" (List
    []),App "IRule" (List [App "()" (List []),App "Nothing" (List []),
    App "Just" (List [App "CxTuple" (List [App "()" (List []),List [
    App "ClassA" (List [App "()" (List []),App "UnQual" (List [App
    "()" (List []),App "Ident" (List [App "()" (List []),String
    "Typeable"])]),List [App "TyVar" (List [App "()" (List []),App
    "Ident" (List [App "()" (List []),String "a"])])]]),App "ClassA" (
    List [App "()" (List []),App "UnQual" (List [App "()" (List []),
    App "Ident" (List [App "()" (List []),String "PlateAll"])]),List [
    App "TyVar" (List [App "()" (List []),App "Ident" (List [App "()"
    (List []),String "a"])]),App "TyVar" (List [App "()" (List []),App
    "Ident" (List [App "()" (List []),String "to"])])]]),App "ClassA"
    (List [App "()" (List []),App "UnQual" (List [App "()" (List []),
    App "Ident" (List [App "()" (List []),String "Uniplate"])]),List [
    App "TyVar" (List [App "()" (List []),App "Ident" (List [App "()"
    (List []),String "to"])])]]),App "ClassA" (List [App "()" (List []
    ),App "UnQual" (List [App "()" (List []),App "Ident" (List [App
    "()" (List []),String "Typeable"])]),List [App "TyVar" (List [App
    "()" (List []),App "Ident" (List [App "()" (List []),String "to"])
    ])]])]])]),App "IHApp" (List [App "()" (List []),App "IHApp" (List
    [App "()" (List []),App "IHCon" (List [App "()" (List []),App
    "UnQual" (List [App "()" (List []),App "Ident" (List [App "()" (
    List []),String "PlateAll"])])]),App "TyParen" (List [App "()" (
    List []),App "TyApp" (List [App "()" (List []),App "TyCon" (List [
    App "()" (List []),App "UnQual" (List [App "()" (List []),App
    "Ident" (List [App "()" (List []),DataName])])]),App "TyVar" (List
    [App "()" (List []),App "Ident" (List [App "()" (List []),String
    "a"])])])])]),App "TyVar" (List [App "()" (List []),App "Ident" (
    List [App "()" (List []),String "to"])])])]),App "Just" (List [
    List [App "InsDecl" (List [App "()" (List []),App "FunBind" (List
    [App "()" (List []),MapCtor (App "Match" (List [App "()" (List [])
    ,App "Ident" (List [App "()" (List []),String "plateAll"]),List [
    App "PParen" (List [App "()" (List []),App "PApp" (List [App "()"
    (List []),App "UnQual" (List [App "()" (List []),App "Ident" (List
    [App "()" (List []),CtorName])]),MapField (App "PVar" (List [App
    "()" (List []),App "Ident" (List [App "()" (List []),Concat (List
    [String "x",ShowInt FieldIndex])])]))])])],App "UnGuardedRhs" (
    List [App "()" (List []),Fold (App "InfixApp" (List [App "()" (
    List []),Tail,App "QVarOp" (List [App "()" (List []),App "UnQual"
    (List [App "()" (List []),App "Symbol" (List [App "()" (List []),
    String "|+"])])]),Head])) (Concat (List [Reverse (MapField (App
    "Var" (List [App "()" (List []),App "UnQual" (List [App "()" (List
    []),App "Ident" (List [App "()" (List []),Concat (List [String "x"
    ,ShowInt FieldIndex])])])]))),List [App "App" (List [App "()" (
    List []),App "Var" (List [App "()" (List []),App "UnQual" (List [
    App "()" (List []),App "Ident" (List [App "()" (List []),String
    "plate"])])]),App "Con" (List [App "()" (List []),App "UnQual" (
    List [App "()" (List []),App "Ident" (List [App "()" (List []),
    CtorName])])])])]]))]),App "Nothing" (List [])]))])])]])])]
-- GENERATED STOP


custom (_,d) [InstDecl x1 x2 x3 _ x5 _ x7] = [InstDecl x1 x2 x3 x4 x5 x6 x7]
    where
        vars = dataDeclVars d
        dd = (if null vars then id else TyParen) $ tyApps (tyCon $ dataDeclName d) (map tyVar vars)
        x4 = concatMap f vars ++ [ClassA (qname x) [tyVar "to"] | x <- ["Typeable","Uniplate"]]
        x6 = [dd, tyVar "to"]
        f v = [ClassA (qname "Typeable") [tyVar v], ClassA (qname "PlateAll") [tyVar v, tyVar "to"]]
