//
//  WizDocumentSortArray.h
//  WizNote
//
//  Created by dzpqzb on 13-3-20.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <iostream>
#include <string>
#include <map>
#include <set>
#include <vector>
#import <algorithm>
#import <exception>
#import "NSString+WizString.h"
#import "WizObject.h"

class CWizStringArray : public std::vector<std::string>
{
    
};
class CWizStringSet: public std::set<std::string>
{
    
};
@interface WizDocument (Sorted)
- (NSString*) groupKeyBySortedType:(CWizDocumentsSortedType)type;
- (NSComparisonResult) compareWithDocument:(WizDocument*)doc byType:(CWizDocumentsSortedType)type;
@end

template <bool t_asc>
class CWizSortedArrayKey
{
    std::string str;
public:
    CWizSortedArrayKey()
    {
    }
    CWizSortedArrayKey(const char* key)
    : str(key)
    {
    }
    CWizSortedArrayKey(const std::string& key)
    : str(key)
    {
    }
    friend bool operator < (const CWizSortedArrayKey& str1, const CWizSortedArrayKey& str2 )
    {
        if (t_asc)
        {
            return strcmp(str1.str.c_str(), str2.str.c_str()) > 0;
        }
        else
        {
            return strcmp(str1.str.c_str(), str2.str.c_str()) < 0;
        }
    }
    friend bool operator == (const CWizSortedArrayKey& str1, const CWizSortedArrayKey& str2 )
    {
        return strcmp(str1.str.c_str(), str2.str.c_str()) == 0;
    }
    friend bool operator == (const CWizSortedArrayKey& str1, const std::string& str2 )
    {
        return strcmp(str1.str.c_str(), str2.c_str()) == 0;
    }
};

typedef  CWizSortedArrayKey<false>  CWizSortedArrayKeyAsc ;
typedef  CWizSortedArrayKey<true> CWizSortedArrayKeyDesc;

template <class TKey, class T>
class CWizSortedArray
{
private:
    std::map<TKey, T> m_data;
public:
    int getCount() const { return (int)m_data.size(); }
    T& getAt(int index)
    {
        int i = 0;
        for (typename std::map<TKey, T>::iterator it = m_data.begin(); it != m_data.end(); it++)
        {
            if (i == index) return it->second;
            i++;
        }
        throw std::exception();
    }
    //
    int indexOf(const std::string& key)
    {
        int i = 0;
        for (typename std::map<TKey, T>::const_iterator it = m_data.begin();
             it != m_data.end();
             it++)
        {
            if (it->first == key)
                return i;
            i++;
        }
        //
        return -1;
    }
    
    int insert(const std::string& key, const T& data, bool& exists)
    {
        exists = false;
        //
        int index = indexOf(key);
        if (-1 != index)
        {
            exists = true;
            return index;
        }
        //
        m_data[key] = data;
        //
        return indexOf(key);
    }
    //
    int insert(const std::string& key, const T& data)
    {
        bool exists = false;
        //
        return insert(key, data, exists);
    }
    //
    int insert(const std::string& key)
    {
        T data;
        return insert(key, data);
    }
    
    void remove(int index)
    {
        int i = 0;
        for (typename std::multimap<TKey, T>::iterator it = m_data.begin();
             it != m_data.end();
             it++)
        {
            if (i == index)
            {
                m_data.erase(it);
                return;
            }
            i++;
        }
    }
    std::vector<T>& allDatas()
    {
        std::vector<T> datas;
        for (typename std::map<TKey, T>::iterator itor = m_data.begin(); itor != m_data.end(); ++itor) {
            datas.push_back(itor->second);
        }
        return datas;
    }
    void clear() { m_data.clear();};
};

template <class TKey, class T>
class CWizSortedMultiArray
{
private:
    std::multimap<TKey, T> m_data;
public:
    int getCount() const { return (int)m_data.size(); }
    T& getAt(int index)
    {
        int i = 0;
        for (typename std::multimap<TKey, T>::iterator it = m_data.begin();
             it != m_data.end();
             it++)
        {
            if (i == index)
                return it->second;
            i++;
        }
        //
        throw std::exception();
    }
    //
    void insert(const std::string& key, const T& data)
    {
        m_data.insert(std::pair<TKey, T>(key, data));
    }
    void remove(int index)
    {
        int i = 0;
        for (typename std::multimap<TKey, T>::iterator it = m_data.begin();
             it != m_data.end();
             it++)
        {
            if (i == index)
            {
                m_data.erase(it);
                return;
            }
            i++;
        }
    }
};

template <class TKey>
class CGroup
{
private:
    std::string groupKey;
    std::string groupName;
    CWizSortedMultiArray<TKey, WizDocument*> arr;
public:
    CGroup()
    {
    }
    //
    CGroup(const char* key, const char* name)
    : groupKey(key)
    , groupName(name)
    {
    }
    CGroup(const std::string& key, const std::string& name)
    : groupKey(key)
    , groupName(name)
    {
    }
    //
    std::string getName()const { return groupName; }
    //
    int insertDocument(const std::string& key, WizDocument* doc)
    {
        arr.insert(key, doc);
        //
        for (int i = 0; i < arr.getCount(); i++)
        {
            if([arr.getAt(i).guid isEqualToString:doc.guid])
                return i;
        }
        //
        return -1;
    }
    //
    int getDocumentCount() const { return arr.getCount(); }
    WizDocument* getAt(int index)
    {
        return arr.getAt(index);
    }
    //
    void remove(int index)
    {
        arr.remove(index);
    }
};



struct IGroups
{
    virtual int getGroupCount() = 0;
    virtual std::string getGroupName(int index) = 0;
    //
    virtual int getDocumentCount(int groupIndex) = 0;
    virtual WizDocument* getDocument(int groupIndex, int docIndex) = 0;
    //
    virtual void insertDocument(WizDocument* doc) = 0;
    virtual void insertDocument(WizDocument* doc, bool& groupCreated, int& groupIndex, int& docIndex) = 0;
    //
    virtual bool removeDocument(NSString* documentGuid, int& groupIndex, int& docIndex, bool& isDeleteGroup) = 0;
    
    virtual void clear()  = 0;
    virtual NSArray* allObjects() = 0;
    virtual int count() = 0;
};



struct IWizSortedMethod
{
    virtual void getGroupKey(WizDocument* doc, std::string& groupKey, std::string& groupName) const = 0;
    virtual std::string getDocumentKey(WizDocument* doc) const = 0;
};

struct IWizSortedMethodByTitle : public IWizSortedMethod
{
    virtual void getGroupKey(WizDocument* doc, std::string& groupKey, std::string& groupName) const
    {
        if(!doc.title)
        {
            groupKey = "#";
            groupName = "#";
        }
        std::string pinyin = [[doc.title pinyinFirstLetter] UTF8String];
        groupKey = pinyin;
        groupName =  pinyin;
    };
    virtual std::string getDocumentKey(WizDocument* doc) const
    {
        return [doc.title UTF8String];
    };
};

struct IWizSortedMethodByModifiedDate : public IWizSortedMethod
{
    virtual void getGroupKey(WizDocument* doc, std::string& groupKey, std::string& groupName) const
    {
        NSString* docDate = [doc.dateModified stringYearAndMounth];
        if(!docDate)
        {
            static std::string date = "1988-08-24 12:00:00";
            groupKey = date;
            groupName = date;
        }
        else
        {
            
            groupKey = [docDate UTF8String];
            groupName = groupKey;
        }
    };
    virtual std::string getDocumentKey(WizDocument* doc) const
    {
        return [[doc.dateModified stringSql] UTF8String];
    };
};

struct IWizSortedMethodByCreatedDate : public IWizSortedMethod {
    virtual void getGroupKey(WizDocument* doc, std::string& groupKey, std::string& groupName) const
    {
        NSString* docDate = [doc.dateCreated stringYearAndMounth];
        if(!docDate)
        {
            static std::string date = "1988-08-24 12:00:00";
            groupKey = date;
            groupName = date;
        }
        else
        {
            
            groupKey = [docDate UTF8String];
            groupName = groupKey;
        }
    };
    virtual std::string getDocumentKey(WizDocument* doc) const
    {
        return [[doc.dateCreated stringSql] UTF8String];
    };
};

template <class TKey, class TSortedMthod>
class CGroups : public IGroups
{
    CWizSortedArray<TKey, CGroup<TKey> > m_groups;
    TSortedMthod sortedMethod;
    //
public:
    
    virtual int getGroupCount() {
        return m_groups.getCount();
    }
    //
    virtual std::string getGroupName(int index)
    {
        CGroup<TKey>& group = m_groups.getAt(index);
        //
        return group.getName();
    }
    virtual int count()
    {
        int sum = 0;
        int groupCount = getGroupCount();
        for (int i = 0; i < groupCount; ++i) {
           CGroup<TKey>& group = m_groups.getAt(i);
            sum += group.getDocumentCount();
        }
        return sum;
    }
    virtual int getDocumentCount(int groupIndex)
    {
        CGroup<TKey>& group = m_groups.getAt(groupIndex);
        return group.getDocumentCount();
    }
    virtual WizDocument* getDocument(int groupIndex, int docIndex)
    {
        CGroup<TKey>& group = m_groups.getAt(groupIndex);
        return group.getAt(docIndex);
    }
    //
    virtual void insertDocument(WizDocument* doc)	//”√”⁄≥ı ºªØ ˝æ›
    {
        int groupIndex = 0;
        int docIndex = 0;
        bool groupCreated = false;
        
        insertDocument(doc, groupCreated, groupIndex, docIndex);
    }
    //
    virtual void insertDocument(WizDocument* doc, bool& groupCreated, int& groupIndex, int& docIndex)
    {
        groupCreated = false;
        //
        std::string groupKey;
        std::string groupName;
        //
        sortedMethod.getGroupKey(doc, groupKey, groupName);
        //
        groupIndex = m_groups.indexOf(groupKey);
        if (-1 == groupIndex)
        {
            groupCreated = true;
            //
            CGroup<TKey> tempGroup(groupKey, groupName);
            groupIndex = m_groups.insert(groupKey, tempGroup);
        }
        //
        CGroup<TKey>& group = m_groups.getAt(groupIndex);
        //
        docIndex = group.insertDocument(sortedMethod.getDocumentKey(doc), doc);
    }
    //
    virtual bool removeDocument(NSString* documentGuid, int& groupIndex, int& docIndex, bool& isDeleteGroup)
    {
        groupIndex = -1;
        docIndex = -1;
        //
        int groupCount = getGroupCount();
        for (int gIndex = 0; gIndex < groupCount; gIndex++)
        {
            CGroup<TKey>& group = m_groups.getAt(gIndex);
            int docCount = group.getDocumentCount();
            //
            for (int dIndex = 0; dIndex < docCount; dIndex++)
            {
                WizDocument* d = group.getAt(dIndex);
                //
                if([documentGuid isEqualToString:d.guid])
                {
                    group.remove(dIndex);
                    groupIndex = gIndex;
                    docIndex = dIndex;
                    if(dIndex == 0 && docCount == 1)
                    {
                        m_groups.remove(gIndex);
                        isDeleteGroup = true;
                    }
                    else
                    {
                        isDeleteGroup = false;
                    }
                    return true;
                }
            }
        }
        //
        return false;
    }
    virtual void clear()
    {
        m_groups.clear();
    }
    virtual NSArray* allObjects()
    {
        NSMutableArray* array = [NSMutableArray array];
        int count = getGroupCount();
        for(int i = 0 ; i < count; ++i)
        {
            CGroup<TKey>& group = m_groups.getAt(i);
             int rowCount = group.getDocumentCount();
            for (int row = 0 ; row < rowCount ; ++row) {
                WizDocument* doc = getDocument(i , row);
                [array addObject:doc];
            }
        }
        return array;
    }
};


class CWizDocumentsGroups
{
private:
    CGroups<CWizSortedArrayKeyAsc, IWizSortedMethodByTitle> titleGroupsAsc;
    CGroups<CWizSortedArrayKeyDesc, IWizSortedMethodByTitle> titleGroupsDesc;
    CGroups<CWizSortedArrayKeyAsc, IWizSortedMethodByModifiedDate> modifiedGroupsAsc;
    CGroups<CWizSortedArrayKeyDesc, IWizSortedMethodByModifiedDate> modifiedGroupsDesc;
    CGroups<CWizSortedArrayKeyAsc, IWizSortedMethodByCreatedDate> createdGroupsAsc;
    CGroups<CWizSortedArrayKeyDesc, IWizSortedMethodByCreatedDate> createdGroupsDesc;
    CWizDocumentsSortedType sortedType;
    IGroups* getCurrentGroup()
    {
        switch(sortedType)
        {
            case CWizDocumentsSortedTypeByTitleAsc:
                return &titleGroupsAsc;
            case CWizDocumentsSortedTypeByModifiedDateAsc:
                return &modifiedGroupsAsc;
            case CWizDocumentsSortedTypeByModifiedDateDesc:
                return &modifiedGroupsDesc;
            case CWizDocumentsSortedTypeByTitleDesc:
                return &titleGroupsDesc;
            case CWizDocumentsSortedTypeByCreatedDateAsc:
                return &createdGroupsAsc;
            case CWizDocumentsSortedTypeByCreatedDateDesc:
                return &createdGroupsDesc;
            default:
                return &titleGroupsAsc;
                break;
        }
    }
public:
    CWizDocumentsGroups():sortedType(CWizDocumentsSortedTypeByTitleAsc){};
    
    virtual int getGroupCount()
    {
        return getCurrentGroup()->getGroupCount();
    }
    virtual std::string getGroupName(int index)
    {
        return getCurrentGroup()->getGroupName(index);
    }
    //
    virtual int getDocumentCount(int groupIndex)
    {
        return getCurrentGroup()->getDocumentCount(groupIndex);
    }
    virtual WizDocument* getDocument(int groupIndex, int docIndex)
    {
        return getCurrentGroup()->getDocument(groupIndex, docIndex);
    }
    //
    virtual void insertDocument(WizDocument* doc)
    {
        getCurrentGroup()->insertDocument(doc);
    }
    virtual void insertDocument(WizDocument* doc, bool& groupCreated, int& groupIndex, int& docIndex)
    {
        getCurrentGroup()->insertDocument(doc, groupCreated, groupIndex, docIndex);
    }
    //
    virtual bool removeDocument(NSString* documentGuid, int& groupIndex, int& docIndex, bool& isDeleteGroup)
    {
        return  getCurrentGroup()->removeDocument(documentGuid, groupIndex, docIndex, isDeleteGroup);
    }
    virtual int count()
    {
        return getCurrentGroup()->count();
    }
    virtual void clear()
    {
        titleGroupsAsc.clear();
        modifiedGroupsAsc.clear();
        modifiedGroupsDesc.clear();
        titleGroupsDesc.clear();
        createdGroupsDesc.clear();
        createdGroupsAsc.clear();
    };
    void setSortedType(CWizDocumentsSortedType type)
    {
        if (sortedType != type) {
            NSArray* existDocs =  getCurrentGroup()->allObjects();
            setDocuments(existDocs, type);
        }
    }
    void setDocuments(const NSArray* array,  CWizDocumentsSortedType type)
    {
        clear();
        sortedType = type;
        for(WizDocument* doc in array)
        {
            try{
                insertDocument(doc);
            }
            catch(...)
            {
                continue;
            }
        }
    };
};
@interface NSMutableArray (WizMutableSortedArray)
@property (nonatomic, strong) NSMutableDictionary* sortedDictionary;
- (NSIndexPath*) insertDocument:(WizDocument*)doc;
- (NSIndexPath*) removeDocument:(NSString*)doc;
- (NSArray*) updateDocument:(WizDocument*)doc;
- (void) reloadDocuments:(NSArray*)documents;
- (WizDocument*) documentForIndexPath:(NSIndexPath*)indexPath;
- (NSInteger) allDocumentCount;
@end
@interface NSMutableArray ( WizDocumentSortArray)
@property (nonatomic,assign) CWizDocumentsSortedType sortedType;
@property (nonatomic, assign, readonly) id groupKey;
@property (nonatomic, assign, readonly) BOOL isSortedTypeReverse;
@end