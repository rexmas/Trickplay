/*------------------------------------------------------------------------------
* Copyright (C) 2003-2006 Ben van Klinken and the CLucene Team
* 
* Distributable under the terms of either the Apache License (Version 2.0) or 
* the GNU Lesser General Public License, as specified in the COPYING file.
------------------------------------------------------------------------------*/
//Includes some standard headers for searching and indexing.
#ifndef _lucene_CLucene_
#define _lucene_CLucene_

#include "CLucene/StdHeader.h"
#include "CLucene/debug/condition.h"
#include "CLucene/debug/mem.h"
#include "CLucene/index/IndexReader.h"
#include "CLucene/index/IndexWriter.h"
#include "CLucene/index/MultiReader.h"
#include "CLucene/index/Term.h"
#include "CLucene/search/IndexSearcher.h"
#include "CLucene/search/MultiSearcher.h"
#include "CLucene/search/DateFilter.h"
#include "CLucene/search/WildcardQuery.h"
#include "CLucene/search/FuzzyQuery.h"
#include "CLucene/search/PhraseQuery.h"
#include "CLucene/search/PrefixQuery.h"
#include "CLucene/search/RangeQuery.h"
#include "CLucene/search/BooleanQuery.h"
#include "CLucene/document/Document.h"
#include "CLucene/document/Field.h"
#include "CLucene/document/DateField.h"
#include "CLucene/store/Directory.h"
#include "CLucene/store/FSDirectory.h"
#include "CLucene/queryParser/QueryParser.h"

//2011.09.16, yongki1.lee add
#include "CLucene/queryParser/MultiFieldQueryParser.h"

//2011.11.08, yongki1.lee add
//#include "CLucene/search/WildcardQuery.h"

#include "CLucene/analysis/standard/StandardAnalyzer.h"
#include "CLucene/analysis/Analyzers.h"
#include "CLucene/util/Reader.h"

#endif